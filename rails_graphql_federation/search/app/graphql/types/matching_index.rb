module Types
  class MatchingIndex < Types::BaseObject
    field :word, String, null: false
    field :entries, [Types::IndexEntry], null: false
  end
end
