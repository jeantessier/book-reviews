module Types
  class MutationType < Types::BaseObject
    field :login, mutation: Mutations::Login
  end
end
