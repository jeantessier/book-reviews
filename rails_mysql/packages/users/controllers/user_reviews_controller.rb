class UserReviewsController < UserPartController
  before_action :set_user_review, only: [ :show ]
  attr_reader :user_review

  # GET /users/:user_id/reviews
  def index
    render json: user.reviews
  end

  # GET /users/:user_id/reviews/:id
  def show
    redirect_to review_url(user_review), status: :see_other
  end

  private

  def set_user_review
    @user_review = user.reviews.find_by!(id: params[:id]) if user
  end
end
