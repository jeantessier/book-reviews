class ApplicationController < ActionController::API
  include JwtPayload

  before_action :decode_jwt
end
