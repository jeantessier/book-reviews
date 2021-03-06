module Types
  class ReviewType < Types::BaseObject
    field :id, ID, null: false
    field :reviewer, Types::UserType, null: false
    field :book, Types::BookType, null: false
    field :body, String, 'The text of the review.', null: false
    field :start, GraphQL::Types::ISO8601Date, 'Date when the reviewer started reading the book.', null: true
    field :stop, GraphQL::Types::ISO8601Date, 'Date when the reviewer finisned reading the book.', null: true

    def reviewer
      load_association(:reviewer).then(&:reviewer)
    end

    def book
      load_association(:book).then(&:book)
    end
  end
end
