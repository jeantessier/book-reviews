class ApplicationController < ActionController::API
  include JwtAuthentication
  include RequestId

  before_action :decode_jwt
  before_action :pull_request_id
end
