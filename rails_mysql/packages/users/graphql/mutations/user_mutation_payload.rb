module Mutations
  class UserMutationPayload < Types::BaseObject
    implements Interfaces::UserErrorPayload

    field :user, User, null: true
  end
end
