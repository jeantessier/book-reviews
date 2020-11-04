class ApplicationController < ActionController::API
  include Knock::Authenticable
  include JwtPayload

  protected

  def set_book
    @book = Book.find(params[:book_id])
  end

  def current_user
    User.find(jwt_payload['sub']) if jwt_payload
  end
end
