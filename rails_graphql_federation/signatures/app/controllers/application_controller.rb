class ApplicationController < ActionController::API
  include RequestId

  before_action :pull_request_id
end
