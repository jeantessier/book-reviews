module Types
  class QueryType < Types::BaseObject
    field :me,
          Types::JwtType,
          null: false,
          description: "Returns the information about the currently logged in user"

    def me
      context[:jwt]
    end
  end
end
