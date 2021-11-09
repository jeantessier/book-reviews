module Types
  class QueryPlan < Types::BaseObject
    field :words, [String], null: false
    field :indices, [Types::MatchingIndex], null: false
    field :results, [Types::MatchingResult], null: false
  end
end
