module Types
  class ReviewType < Types::BaseObject
    field :id, ID, null: false
    field :reviewer, Types::UserType, null: false
    field :book, Types::BookType, null: false
    field :body, String, 'The text of the review.', null: false
    field :start, GraphQL::Types::ISO8601Date, 'Date when the reviewer started reading the book.', null: true
    field :stop, GraphQL::Types::ISO8601Date, 'Date when the reviewer finisned reading the book.', null: true

    def reviewer
      GraphQL::BatchLoaders::RecordLoader.for(User).load(object.reviewer_id.to_s)
    end

    def book
      GraphQL::BatchLoaders::RecordLoader.for(Book).load(object.book_id.to_s)
    end
  end
end
