class BookYearsController < BookPartController
  before_action :set_book_year, only: [ :show, :update, :destroy ]
  attr_reader :book_year

  # GET /books/:book_id/years
  def index
    render json: book.years.sort
  end

  # GET /books/:book_id/years/:id
  def show
    render json: book_year
  end

  # POST /books/:book_id/years
  def create
    book.years.create!(book_year_params)
    render json: book, status: :created

    rescue
      render json: { error: $! }, status: :unprocessable_content
  end

  # PATCH/PUT /books/:book_id/years/:id
  def update
    if book_year.update(book_year_params)
      render json: book_year
    else
      render json: book_year.errors, status: :unprocessable_content
    end

    rescue
      render json: { error: $! }, status: :unprocessable_content
  end

  # DELETE /books/:book_id/years/:id
  def destroy
    book_year.destroy
  end

  private

  def set_book_year
    @book_year = book.years.find_by!(id: params[:id]) if book
  end

  def book_year_params
    params.require(:book_year).permit(:book_id, :year, :order)
  end
end
