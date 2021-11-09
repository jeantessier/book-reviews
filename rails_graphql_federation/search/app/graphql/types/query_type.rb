module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :query_plan, Types::QueryPlan, null: false do
      argument :q, String, required: true
    end

    field :search, [Types::SearchResult], null: false do
      argument :q, String, required: true
    end

    def query_plan(q:)
      {
        words: [],
        indices: [],
        results: [],
      }
    end

    def search(q:)
      []
    end
  end
end
