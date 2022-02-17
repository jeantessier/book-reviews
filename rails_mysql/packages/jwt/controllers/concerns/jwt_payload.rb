module JwtPayload
  attr_reader :current_user
  attr_reader :jwt_token

  TOKEN_REGEX = /Bearer (?<token>\S+)/

  def decode_jwt
    header_value = request.headers['Authorization']
    md = TOKEN_REGEX.match(header_value)
    return unless md

    begin
      @jwt_token = md[:token]
      @current_user = JWT.decode(md[:token], ENV['JWT_SECRET'], true, { algorithm: 'HS256' }).first.transform_keys(&:to_sym)
    rescue JWT::ExpiredSignature
      # Ignore
    end
  end
end
