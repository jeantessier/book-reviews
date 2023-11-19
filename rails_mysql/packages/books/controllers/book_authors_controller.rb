class BookAuthorsController < BookPartController
  before_action :set_book_author, only: [:show, :update, :destroy]
  attr_reader :book_author

  # GET /books/:book_id/authors
  def index
    render json: book.authors.sort
  end

  # GET /books/:book_id/authors/:id
  def show
    render json: book_author
  end

  # POST /books/:book_id/authors
  def create
    book.authors.create!(book_author_params)
    render json: book, status: :created

    rescue
      render json: {error: $!}, status: :unprocessable_entity
  end

  # PATCH/PUT /books/:book_id/authors/:id
  def update
    if book_author.update(book_author_params)
      render json: book_author
    else
      render json: book_author.errors, status: :unprocessable_entity
    end

    rescue
      render json: {error: $!}, status: :unprocessable_entity
  end

  # DELETE /books/:book_id/authors/:id
  def destroy
    book_author.destroy
  end

  private

  def set_book_author
    @book_author = book.authors.find_by!(id: params[:id]) if book
  end

  def book_author_params
    params.require(:book_author).permit(:author, :order)
  end
end
