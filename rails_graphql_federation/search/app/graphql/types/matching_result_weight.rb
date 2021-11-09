module Types
  class MatchingResultWeight < Types::BaseObject
    field :word, String, null: false
    field :weight, Float, null: false
  end
end
