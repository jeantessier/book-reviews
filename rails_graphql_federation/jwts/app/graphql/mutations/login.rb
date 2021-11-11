module Mutations
  class Login < Mutations::BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    field :jwt, String, 'a signed JWT for the user with matching email and password', null: true

    def resolve(email:, password:)
      user = UserRepository.find_by_email(email)
      raise "No user with email \"#{email}\"." if user.nil?

      raise "Password for #{email} does not match." unless user[:password] == password

      { jwt: generate_jwt(user) }
    end

    private

    def generate_jwt(user)
      payload = {
        name: user[:name],
        email: user[:email],
        roles: user[:roles],
      }
      options = {
        expiresIn: 3 * 24 * 60 *  60, # 3 days in seconds
        issuer: 'book-reviews',
        subject: user[:id],
      }
      payload.merge(options).to_json
    end
  end
end