class BookYearsController < ApplicationController
  before_action :set_book_year, only: [:show, :update, :destroy]

  # GET /book_years
  def index
    @book_years = BookYear.all

    render json: @book_years
  end

  # GET /book_years/1
  def show
    render json: @book_year
  end

  # POST /book_years
  def create
    @book_year = BookYear.new(book_year_params)

    if @book_year.save
      render json: @book_year, status: :created, location: @book_year
    else
      render json: @book_year.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /book_years/1
  def update
    if @book_year.update(book_year_params)
      render json: @book_year
    else
      render json: @book_year.errors, status: :unprocessable_entity
    end
  end

  # DELETE /book_years/1
  def destroy
    @book_year.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book_year
      @book_year = BookYear.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def book_year_params
      params.require(:book_year).permit(:book_id, :year, :order)
    end
end
