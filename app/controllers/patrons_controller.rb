class PatronsController < ApplicationController
  before_action :set_Patron, only: [:edit, :update, :show, :destroy]

  def index
    if params[:search]
      debugger
      @patrons = Patron.search(params[:search]).order("created_at DESC")
    else
      @patrons = Patron.all.order("created_at DESC")
    end
  end

  def show
    @patrons_id = params[:id]
    @patronIds = []
    @bookIds = []

    @transactiondata = Transaction.joins("INNER JOIN patrons ON #{@patrons_id} = transactions.patron_id
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
    @patron_books_details = @alltransactiondata
  end

  def new
    @patron = Patron.new
  end

  def create
    # debugger
    # puts params[:name]
    @patron = Patron.new(name: params[:name], contact_information: params[:contact_information])
    if @patron.save!
      redirect_to action: :index
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @patron = Patron.find(params[:id])

  end

  def update
    #  @patron = Patron.find(params[:id])
    if @patron.update(patron_params)
      redirect_to action: :index
    else
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    # @patron = Patron.find(params[:id])
    if @patron.destroy
      redirect_to action: "index"
    end
  end

  private

  def set_Patron
    @patron = Patron.find(params[:id])
  end

  def patron_params
    params.require(:patron).permit(:name, :contact_information)
  end
end
