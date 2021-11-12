module Types
  class ReviewType < Types::BaseObject
    field :id, ID, null: false
    field :reviewer, Types::UserType, null: false
    field :book, Types::BookType, null: false
    field :body, String, null: false
    field :start, String, null: true
    field :stop, String, null: true

    key fields: 'id'

    def self.resolve_reference(reference, _context)
      ReviewRepository.find_by_id(reference[:id])
    end
  end
end
