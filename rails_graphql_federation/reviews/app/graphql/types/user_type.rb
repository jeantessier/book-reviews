module Types
  class UserType < Types::BaseObject
    extend_type

    field :id, ID, null: false, external: true
    field :reviews, [Types::ReviewType], null: false
    field :books, [Types::BookType], null: false

    key fields: 'id'

    def reviews
      []
    end

    def books
      []
    end
  end
end
