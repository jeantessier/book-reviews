module Mutations
  class SignInMutation < Mutations::BaseMutation
    description 'Signs in the user based on their credentials and returns a JWT to make authenticated calls.'

    argument :email, String, required: true
    argument :password, String, required: true

    object_class Mutations::SignInMutationPayload

    field :jwt, String, null: true

    # Inspired by Knock::AuthTokenController.
    # The error messages are too verbose for real sign in error message.
    # They are just to illustrate all that can be done with UserError.
    def resolve(email:, password:)
      user = User.find_by(email: email)

      if user.present?
        if user.authenticate(password)
          auth_token = Knock::AuthToken.new payload: user.to_token_payload
        else
          add_user_error argument: :password, message: "Password \"#{password}\" didn't match."
        end
      else
        add_user_error argument: :email, message: "No user with email \"#{email}\"."
      end

      with_user_errors jwt: auth_token&.token
    end
  end
end
