module Types
  class BookType < Types::BaseObject
    extend_type

    field :id, ID, null: false, external: true
    field :reviews, [Types::ReviewType], null: false
    field :reviewers, [Types::UserType], null: false

    key fields: 'id'

    def reviews
      []
    end

    def reviewers
      []
    end
  end
end
