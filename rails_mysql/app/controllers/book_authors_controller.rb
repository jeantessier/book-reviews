class BookAuthorsController < ApplicationController
  before_action :authenticate_user, only: [:create, :update, :destroy]
  before_action :set_book
  before_action :set_book_author, only: [:show, :update, :destroy]

  # GET /books/:book_id/book_authors
  def index
    render json: @book.authors
  end

  # GET /books/:book_id/book_authors/1
  def show
    render json: @book_author
  end

  # POST /books/:book_id/book_authors
  def create
    @book.authors.create!(book_author_params)
    render json: @book, status: :created

    rescue
      render json: {error: $!}, status: :unprocessable_entity
  end

  # PATCH/PUT /books/:book_id/book_authors/1
  def update
    if @book_author.update(book_author_params)
      render json: @book_author
    else
      render json: @book_author.errors, status: :unprocessable_entity
    end

    rescue
      render json: {error: $!}, status: :unprocessable_entity
  end

  # DELETE /books/:book_id/book_authors/1
  def destroy
    @book_author.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book_author
      @book_author = @book.authors.find_by!(id: params[:id]) if @book
    end

    # Only allow a trusted parameter "white list" through.
    def book_author_params
      params.require(:book_author).permit(:name, :order)
    end
end
