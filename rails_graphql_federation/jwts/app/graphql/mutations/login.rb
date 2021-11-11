module Mutations
  class Login < Mutations::BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    field :jwt, String, 'a signed JWT for the user with matching email and password', null: true

    def resolve(email:, password:)
      { jwt: "" }
    end
  end
end