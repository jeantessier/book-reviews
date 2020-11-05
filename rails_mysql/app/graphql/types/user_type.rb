module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :name, String, null: false
    field :reviews, [Types::ReviewType], null: false
    field :books, [Types::BookType], null: false
  end
end
