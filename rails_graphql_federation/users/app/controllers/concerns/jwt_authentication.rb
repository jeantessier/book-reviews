module JwtAuthentication
  attr_reader :current_user

  private

  TOKEN_REGEX = /Bearer (?<token>\S+)/

  def decode_jwt
    header_value = request.headers["Authorization"]
    md = TOKEN_REGEX.match(header_value)
    return unless md

    begin
      @current_user = JWT.decode(md[:token], ENV["JWT_SECRET"], true, { algorithm: "HS256" }).first.transform_keys(&:to_sym)
    rescue JWT::ExpiredSignature
      # Ignore
    end
  end
end
