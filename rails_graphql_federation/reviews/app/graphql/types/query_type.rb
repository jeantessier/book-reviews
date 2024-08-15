module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :reviews,
      [ Types::ReviewType ],
      null: false,
      description: "Returns all the reviews in the system, possibly filtered for a specific reviewer." do
        argument :for_reviewer, ID, required: false
      end

    field :review,
      Types::ReviewType,
      null: true,
      description: "Returns a specific review by its ID." do
        argument :id, ID, required: true
      end

    def reviews(for_reviewer: nil)
      for_reviewer.nil? ? ReviewRepository.all : ReviewRepository.all.find_all { |r| r[:reviewer][:id] == for_reviewer }
    end

    def review(id:)
      ReviewRepository.find_by_id(id)
    end
  end
end
