module Types
  class MatchingResult < Types::BaseObject
    field :weights, [ Types::MatchingResultWeight ], null: false
    field :total_weight, Float, null: false
    field :id, ID, null: false
    field :type, String, null: false
  end
end
