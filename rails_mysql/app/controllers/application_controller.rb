class ApplicationController < ActionController::API
  include Knock::Authenticable
  include JwtPayload
  undef_method :current_user
end
