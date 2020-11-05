module Mutations
  class SignInMutation < Mutations::BaseMutation
    description 'Signs in the user based on their credentials and returns a JWT to make authenticated calls.'

    argument :email, String, required: true
    argument :password, String, required: true

    field :jwt, String, null: true

    # Inspired by Knock::AuthTokenController
    def resolve(email:, password:)
      user = User.find_by(email: email)
      raise GraphQL::ExecutionError, "Authentication failure" unless user.present? && user.authenticate(password)

      auth_token = Knock::AuthToken.new payload: user.to_token_payload
      {
        jwt: auth_token.token
      }
    end
  end
end
