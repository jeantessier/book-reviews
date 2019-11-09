class BookYearsController < ApplicationController
  before_action :authenticate_user, only: [:create, :update, :destroy]
  before_action :set_book
  before_action :set_book_year, only: [:show, :update, :destroy]

  # GET /books/:book_id/book_years
  def index
    render json: @book.years
  end

  # GET /books/:book_id/book_years/1
  def show
    render json: @book_year
  end

  # POST /books/:book_id/book_years
  def create
    @book.years.create!(book_year_params)
    render json: @book, status: :created

    rescue
      render json: {error: $!}, status: :unprocessable_entity
  end

  # PATCH/PUT /books/:book_id/book_years/1
  def update
    if @book_year.update(book_year_params)
      render json: @book_year
    else
      render json: @book_year.errors, status: :unprocessable_entity
    end

    rescue
      render json: {error: $!}, status: :unprocessable_entity
  end

  # DELETE /books/:book_id/book_years/1
  def destroy
    @book_year.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book_year
      @book_year = @book.years.find_by!(id: params[:id]) if @book
    end

    # Only allow a trusted parameter "white list" through.
    def book_year_params
      params.require(:book_year).permit(:book_id, :year, :order)
    end
end
