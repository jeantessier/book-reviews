module Types
  class MutationType < Types::BaseObject
    field :sign_in, mutation: Mutations::SignInMutation
    field :user, mutation: Mutations::UserMutation
  end
end
