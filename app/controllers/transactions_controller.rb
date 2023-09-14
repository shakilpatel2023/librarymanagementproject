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

      @transactiondata = Transaction.joins("INNER JOIN patrons ON patrons.id = transactions.patron_id
        INNER JOIN books ON books.id = transactions.book_id")

      @alltransactiondata = []

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
      @transaction = Transaction.new(date: Date.today, return_date: Date.today + 30, patron_id: @patron.id, book_id: @book.id)

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
    # @transaction = Transaction.find(params[:id])
  end

  def update
    if @transaction
      redirect_to action: :index
    else
      render :index, status: :unprocessable_entity
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
end
