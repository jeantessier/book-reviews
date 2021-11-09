module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :books,
      [Types::BookType],
      null: false,
      description: "Returns all the books in the system."

    field :book,
      Types::BookType,
      null: true,
      description: "Returns a specific book by its ID." do
        argument :book_id, ID, required: true
      end

    def books
      BookRepository.all
    end

    def book(book_id:)
      BookRepository.find_by_id(book_id)
    end
  end
end
