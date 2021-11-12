module Types
  class UserType < Types::BaseObject
    extend_type

    field :id, ID, null: false, external: true
    field :reviews, [Types::ReviewType], null: false
    field :books, [Types::BookType], null: false

    key fields: 'id'

    def reviews
      ReviewRepository.find_all_by_reviewer(object[:id])
    end

    def books
      reviews.map { |r| r[:book] }
    end
  end
end
