module Types
  class SearchResult < Types::BaseUnion
    possible_types Types::BookType, Types::ReviewType, Types::UserType
  end
end
