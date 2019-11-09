class ApplicationController < ActionController::API
  include Knock::Authenticable
  include JwtPayload
  undef_method :current_user

  protected

  def set_book
    @book = Book.find(params[:book_id])
  end
end
