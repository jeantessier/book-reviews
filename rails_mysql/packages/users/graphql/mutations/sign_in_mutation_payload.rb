module Mutations
  class SignInMutationPayload < Types::BaseObject
    implements Interfaces::UserErrorPayload

    field :jwt, String, null: true
  end
end
