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
      @alltransactiondata = []

      @transactionlatefee = Transaction.all

      @transactionlatefee.each do |data|
        if Date.parse(data.return_date.to_s) < Date.parse(data.date_for_late_fee.to_s) && Date.parse(data.date_for_late_fee.to_s) == Date.parse(Date.today.to_s)
          if data.late_fee > 0
            transaction_record = Transaction.find(data.id)
            transaction_record.update(late_fee: 0)
          end
          transaction_record_update = Transaction.find(data.id)
          @dateforlatefee = 1.day.from_now(data.date_for_late_fee)
          transaction_record_update.late_fee = transaction_record_update.late_fee + 10
          transaction_record_update.update(late_fee: transaction_record_update.late_fee, date_for_late_fee: @dateforlatefee)
        elsif Date.parse(data.return_date.to_s) == Date.parse(Date.today.to_s)
          if data.late_fee > 0
            transaction_record = Transaction.find(data.id)
            transaction_record.update(late_fee: 0)
          end
          transaction_record_update = Transaction.find(data.id)
          @dateforlatefee = 1.day.from_now(data.return_date)
          transaction_record_update.late_fee = transaction_record_update.late_fee + 10
          transaction_record_update.update(late_fee: transaction_record_update.late_fee, date_for_late_fee: @dateforlatefee)
        elsif Date.parse(data.return_date.to_s) < Date.parse(data.date_for_late_fee.to_s) && Date.parse(data.date_for_late_fee.to_s) < Date.parse(Date.today.to_s)
          if data.late_fee > 0
            transaction_record = Transaction.find(data.id)
            transaction_record.update(late_fee: 0)
          end
          transaction_record_update = Transaction.find(data.id)
          @beginDate = Date.parse(Date.today.to_s)
          @endDate = Date.parse(data.date_for_late_fee.to_s)
          @days = (@beginDate - @endDate).to_i
          @dateforlatefee = 1.day.from_now(Date.today)
          transaction_record_update.late_fee = transaction_record_update.late_fee + 10 * @days

          transaction_record_update.update(late_fee: transaction_record_update.late_fee, date_for_late_fee: @dateforlatefee)
        elsif Date.parse(data.return_date.to_s) == Date.parse(data.date_for_late_fee.to_s) && Date.parse(data.date_for_late_fee.to_s) < Date.parse(Date.today.to_s)
          if data.late_fee > 0
            transaction_record = Transaction.find(data.id)
            transaction_record.update(late_fee: 0)
          end
          transaction_record_update = Transaction.find(data.id)
          @beginDate = Date.today
          @endDate = data.return_date
          @days = (@beginDate - @endDate).to_i
          @dateforlatefee = 1.day.from_now(Date.today)
          transaction_record_update.late_fee = transaction_record_update.late_fee + 10 * @days
          transaction_record_update.update(late_fee: transaction_record_update.late_fee, date_for_late_fee: @dateforlatefee)
        elsif Date.parse(data.return_date.to_s) < Date.parse(Date.today.to_s)
          if data.late_fee > 0
            transaction_record = Transaction.find(data.id)
            transaction_record.update(late_fee: 0)
          end
          transaction_record_update = Transaction.find(data.id)
          @beginDate = Date.today
          @endDate = data.return_date
          @days = (@beginDate - @endDate).to_i
          @dateforlatefee = 1.day.from_now(Date.today)
          transaction_record_update.late_fee = transaction_record_update.late_fee + 10 * @days
          transaction_record_update.update(late_fee: transaction_record_update.late_fee, date_for_late_fee: @dateforlatefee)
        else
        end
      end

      @transactiondata = Transaction.joins("INNER JOIN patrons ON patrons.id = transactions.patron_id
        INNER JOIN books ON books.id = transactions.book_id")

      @transactiondata.each do |data|
        @patronIds << data.patron_id
        @bookIds << data.book_id
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
    if @transaction.destroy
      redirect_to action: "index"
    end
  end

  def edit_return_book
    @transaction_return_book = Transaction.find(params[:transaction_id])
  end

  def update_return_book
    @transaction_return_book = Transaction.find(params[:transaction_id])

    if params[:late_fee].present? && @transaction_return_book.update(late_fee: params[:late_fee])
      @book = Book.find_by(ISBN: params[:ISBN])
      @book_quantity_added = (@book.book_quantity + 1)

      if @book.update(book_quantity: @book_quantity_added)
        if @transaction_return_book.destroy
          redirect_to action: "index"
        end
      else
        redirect_to action: "edit_return_book"
      end
    elsif @transaction_return_book.late_fee == 0 && @transaction_return_book.update(late_fee: params[:late_fee])
      @book = Book.find_by(ISBN: params[:ISBN])
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
