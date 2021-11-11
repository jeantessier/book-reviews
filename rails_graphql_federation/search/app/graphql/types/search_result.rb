module Types
  class SearchResult < Types::BaseUnion
    possible_types Types::BookType, Types::ReviewType, Types::UserType

    def self.resolve_type(object, _context)
      case object[:__typename]
      when 'Book'
        Types::BookType
      when 'Review'
        Types::ReviewType
      when 'User'
        Types::UserType
      else
        raise "Unknown type for SearchResult #{object}"
      end
    end
  end
end
