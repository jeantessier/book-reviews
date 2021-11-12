module Types
  class BookType < Types::BaseObject
    extend_type

    field :id, ID, null: false, external: true
    field :reviews, [Types::ReviewType], null: false
    field :reviewers, [Types::UserType], null: false

    key fields: 'id'

    def reviews
      ReviewRepository.find_all_by_book(object[:id])
    end

    def reviewers
      reviews.map { |r| r[:reviewer] }
    end
  end
end
