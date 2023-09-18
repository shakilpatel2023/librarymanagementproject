class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:edit, :update, :show, :destroy]

  def index
    if params[:search]
      @search_results = Transaction.search(params[:search])
      @search_results += Patron.search(params[:search])
      @search_results += Book.search(params[:search])

      @transactions = @search_results
    else
      @patronIds = []
      @bookIds = []
      @days = 1
      @dateforlatefee = 1.day.from_now(Date.today)
      @handleRecounting = 0

      @transactiondata = Transaction.joins("INNER JOIN patrons ON patrons.id = transactions.patron_id
        INNER JOIN books ON books.id = transactions.book_id")

      @alltransactiondata = []

      @transactiondata.each do |data|
        @patronIds << data.patron_id
        @bookIds << data.book_id

        begin
          if Date.parse(data.return_date.to_s) < Date.parse(data.date_for_late_fee.to_s) && Date.parse(Date.today.to_s) > Date.parse(data.date_for_late_fee.to_s)
            @beginDate = Date.parse(Date.today.to_s)
            @endDate = Date.parse(data.date_for_late_fee.to_s)
            @days = (@beginDate - @endDate).to_i
            @dateforlatefee = 1.day.from_now(data.date_for_late_fee)
            @handleRecounting += 1
          elsif Date.parse(data.return_date.to_s) == Date.parse(data.date_for_late_fee.to_s) && Date.parse(Date.today.to_s) > Date.parse(data.return_date.to_s)
            @beginDate = Date.parse(Date.today.to_s)
            @endDate = Date.parse(data.return_date.to_s)
            @days = (@beginDate - @endDate).to_i
            @dateforlatefee = 1.day.from_now(Date.today)
            @handleRecounting += 1
          elsif Date.parse(data.return_date.to_s) < Date.parse(Date.today.to_s)
            @beginDate = Date.parse(Date.today.to_s)
            @endDate = Date.parse(data.return_date.to_s)
            @days = (@beginDate - @endDate).to_i
            @dateforlatefee = 1.day.from_now(data.return_date.to_s)
            @handleRecounting += 1
          else
            # Handle other cases here
          end
        rescue Error => e
          puts "Error: #{e.message}"
        end

        if @handleRecounting == 1
          # puts "------#{@days}"
          data.late_fee += data.late_fee + 10 * @days
          @transactiondata.update(late_fee: data.late_fee, date_for_late_fee: @dateforlatefee)
        end

        @alltransactiondata << data
      end

      @patronsdata = Patron.where(id: @patronIds)
      @booksdata = Book.where(id: @bookIds)

      @alltransactiondata += @patronsdata + @booksdata
      @transactions = @alltransactiondata
    end
  end

  def show
    # @Transaction = Transaction.find(params[:id])
  end

  def new
    @patron = Patron.find(params[:patron_id])
    @transaction = Transaction.new
  end

  def create
    @patron = Patron.find(params[:patron_id])
    @book = Book.find_by(ISBN: params[:transaction][:ISBN])

    if @book.book_quantity > 0
      @transaction_params_data = { date: Date.today, return_date: Date.today + 30, date_for_late_fee: Date.today + 30, late_fee: 0, patron_id: @patron.id, book_id: @book.id }
      @transaction = Transaction.new(@transaction_params_data)
      if @transaction.save!
        @updatedQuantity = (@book.book_quantity - 1)
        if @book.update(book_quantity: @updatedQuantity)
          redirect_to action: :index
        end
      else
        render :new, status: :unprocessable_entity
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @transaction = Transaction.find(params[:id])
    @results1 = Patron.find(@transaction.patron_id)
    @results2 = Book.find(@transaction.book_id)

    @transaction.patron = @results1
    @transaction.book = @results2
  end

  def update
    @transaction = Transaction.find(params[:id])
    if @transaction.update(transaction_params)
      @transaction.patron.update(patron_params)
      @transaction.book.update(book_params)
      redirect_to action: :index
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # @transaction = Transaction.find(params[:id])
    if @transaction.destroy
      redirect_to action: "index"
    end
  end

  def edit_return_book
    @transaction = Transaction.find(params[:transaction_id])
    @transaction_return_book = Book.find(@transaction.book_id)
  end

  def update_return_book
    @transaction_return_book = Transaction.find(params[:transaction_id])

    if @transaction_return_book
      @book = Book.find_by(ISBN: params[:transaction][:ISBN])
      @book_quantity_added = (@book.book_quantity + 1)

      if @book.update(book_quantity: @book_quantity_added)
        if @transaction_return_book.destroy
          redirect_to action: "index"
        end
      else
        redirect_to action: "edit_return_book"
      end
    else
      redirect_to action: "edit_return_book"
    end
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def transaction_params
    permitted_params = params.require(:transaction).permit(:date, :return_date, :late_fee)

    @transaction = Transaction.find(params[:id])

    if Date.parse(@transaction.return_date.to_s) != Date.parse(params[:transaction][:return_date].to_s)
      permitted_params[:date_for_late_fee] = params[:transaction][:return_date]
    end

    permitted_params
  end

  def patron_params
    params.require(:transaction).permit(:name, :contact_information)
  end

  def book_params
    params.require(:transaction).permit(:title, :author, :ISBN)
  end
end
