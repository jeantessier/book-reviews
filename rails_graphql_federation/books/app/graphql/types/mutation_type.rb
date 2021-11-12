module Types
  class MutationType < Types::BaseObject
    field :add_book, mutation: Mutations::AddBook
    field :update_book, mutation: Mutations::UpdateBook
    field :remove_book, mutation: Mutations::RemoveBook
  end
end
