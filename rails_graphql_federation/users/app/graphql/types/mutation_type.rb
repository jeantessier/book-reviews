module Types
  class MutationType < Types::BaseObject
    field :sign_up, mutation: Mutations::SignUp
    field :add_user, mutation: Mutations::AddUser
    field :update_user, mutation: Mutations::UpdateUser
    field :remove_user, mutation: Mutations::RemoveUser
  end
end
