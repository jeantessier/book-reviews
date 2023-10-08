class BookReviewsController < BookPartController
  before_action :set_book_review, only: [:show]

  # GET /books/:book_id/reviews
  def index
    render json: book.reviews
  end

  # GET /books/:book_id/reviews/:id
  def show
    redirect_to review_url(@book_review), status: :see_other
  end

  private

  def set_book_review
    @book_review = book.reviews.find_by!(id: params[:id]) if book
  end
end