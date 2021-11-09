module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :users,
      [Types::UserType],
      null: false,
      description: "Returns all the users in the system."

    field :user,
      Types::UserType,
      null: true,
      description: "Returns a specific user by its ID." do
      argument :user_id, ID, required: true
    end

    def users
      []
    end

    def user(user_id:)
    end
  end
end
