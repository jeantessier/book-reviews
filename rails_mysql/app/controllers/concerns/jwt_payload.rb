module JwtPayload
  def jwt_payload
    token ? Knock::AuthToken.new(token: token).payload : {}
  rescue
    return {}
  end
end
