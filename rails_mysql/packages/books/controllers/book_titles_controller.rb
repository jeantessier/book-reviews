class BookTitlesController < BookPartController
  before_action :set_book_title, only: [:show, :update, :destroy]

  # GET /books/:book_id/book_titles
  def index
    render json: book.titles.sort
  end

  # GET /books/:book_id/book_titles/1
  def show
    render json: @book_title
  end

  # POST /books/:book_id/book_titles
  def create
    book.titles.create!(book_title_params)
    render json: book, status: :created

    rescue
      render json: {error: $!}, status: :unprocessable_entity
  end

  # PATCH/PUT /books/:book_id/book_titles/1
  def update
    if @book_title.update(book_title_params)
      render json: @book_title
    else
      render json: @book_title.errors, status: :unprocessable_entity
    end

    rescue
      render json: {error: $!}, status: :unprocessable_entity
  end

  # DELETE /books/:book_id/book_titles/1
  def destroy
    @book_title.destroy
  end

  private

  def set_book_title
    @book_title = book.titles.find_by!(id: params[:id]) if book
  end

  def book_title_params
    params.require(:book_title).permit(:book_id, :title, :link, :order)
  end
end
