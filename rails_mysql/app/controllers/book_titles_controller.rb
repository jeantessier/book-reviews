class BookTitlesController < ApplicationController
  before_action :set_book_title, only: [:show, :update, :destroy]

  # GET /book_titles
  def index
    @book_titles = BookTitle.all

    render json: @book_titles
  end

  # GET /book_titles/1
  def show
    render json: @book_title
  end

  # POST /book_titles
  def create
    @book_title = BookTitle.new(book_title_params)

    if @book_title.save
      render json: @book_title, status: :created, location: @book_title
    else
      render json: @book_title.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /book_titles/1
  def update
    if @book_title.update(book_title_params)
      render json: @book_title
    else
      render json: @book_title.errors, status: :unprocessable_entity
    end
  end

  # DELETE /book_titles/1
  def destroy
    @book_title.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book_title
      @book_title = BookTitle.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def book_title_params
      params.require(:book_title).permit(:book_id, :title, :link, :order)
    end
end
