module Types
  class UserPayload < Types::BaseObject
    implements Interfaces::UserErrorPayload

    field :user, Types::UserType, null: true
  end
end