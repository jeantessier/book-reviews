module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :me,
      Types::UserType,
      null: true,
      description: "Returns the currently logged in user"

    field :users,
      [ Types::UserType ],
      null: false,
      description: "Returns all the users in the system."

    field :user,
      Types::UserType,
      null: true,
      description: "Returns a specific user by its ID." do
        argument :id, ID, required: true
      end

    def me
      Rails.logger.info "current_user: #{context[:current_user]}"
      UserRepository.find_by_id(context[:current_user][:sub]) unless context[:current_user].nil?
    end

    def users
      UserRepository.all
    end

    def user(id:)
      UserRepository.find_by_id(id)
    end
  end
end
