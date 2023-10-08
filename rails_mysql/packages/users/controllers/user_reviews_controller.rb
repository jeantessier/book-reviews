class UserReviewsController < UserPartController
  before_action :set_user_review, only: [:show]

  # GET /users/:user_id/reviews
  def index
    render json: user.reviews
  end

  # GET /users/:user_id/reviews/:id
  def show
    render json: @user_review
  end

  private

  def set_user_review
    @user_review = user.reviews.find_by!(id: params[:id]) if user
  end
end