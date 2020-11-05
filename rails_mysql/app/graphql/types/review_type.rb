module Types
  class ReviewType < Types::BaseObject
    field :id, ID, null: false
    field :reviewer, Types::UserType, null: false
    field :book, Types::BookType, null: false
    field :body, String, null: false
    field :start, GraphQL::Types::ISO8601Date, null: true
    field :stop, GraphQL::Types::ISO8601Date, null: true
  end
end
