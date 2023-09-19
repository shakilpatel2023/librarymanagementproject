class BooksController < ApplicationController
  before_action :set_book, only: [:edit, :update, :show, :destroy]

  def index
    if params[:search]
      @books = Book.search(params[:search]).order("created_at DESC")
    else
      @books = Book.all.order("created_at DESC")
      # img = ActiveStorage::Attachment.find_by(record_id: 7)

      # blob = ActiveStorage::Blob.find(img.id) # Replace with the ID of the blob you want to retrieve

      # if blob
      #   full_url = Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
      #   # full_url will contain the full URL of the blob, including the host
      #   puts "Full URL of #{blob.filename}: #{full_url}" # Use blob.filename to display the actual filename
      # else
      #   puts "Blob with ID '1' not found." # Update the message if needed
      # end
    end
  end

  def show
    # @book = Book.find(params[:id])
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    image = params[:image]

    if image.present?
      @book.image.attach(image)
    end

    if @book.save!
      redirect_to action: "index"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @book = Book.find(params[:id])
  end

  def update
    # @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to action: "index"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # @book = Book.find(params[:id])
    if @book.destroy
      redirect_to action: "index"
    end
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :author, :ISBN, :book_quantity)
  end
end
