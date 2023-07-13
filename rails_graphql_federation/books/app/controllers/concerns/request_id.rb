module RequestId
  attr_reader :request_id

  private

  def pull_request_id
    @request_id = request.request_id
  end
end