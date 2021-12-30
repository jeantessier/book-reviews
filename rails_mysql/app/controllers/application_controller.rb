class ApplicationController < ActionController::API
  include Knock::Authenticable
  include JwtPayload

  protected

  def current_user
    User.find_by(id: jwt_payload['sub']) if jwt_payload
  end
end
