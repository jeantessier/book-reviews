module Types
  class QueryType < Types::BaseObject
    field :me,
          Types::UserType,
          null: true,
          description: "Returns the currently logged in user"

    def me
      context[:current_user]
    end
  end
end
