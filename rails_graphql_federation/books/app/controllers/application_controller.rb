class ApplicationController < ActionController::API
  before_action :decode_jwt

  attr_reader :current_user

  private

  TOKEN_REGEX = /Bearer (?<token>\S+)/

  def decode_jwt
    header_value = request.headers['HTTP_AUTHORIZATION']
    md = TOKEN_REGEX.match(header_value)
    return unless md

    begin
      @current_user = JWT.decode(md[:token], ENV['JWT_SECRET'], true, { algorithm: 'HS256' }).first
    rescue JWT::ExpiredSignature
      # Ignore
    end
  end
end
