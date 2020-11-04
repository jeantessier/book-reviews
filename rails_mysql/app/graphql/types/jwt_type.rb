module Types
  class JwtType < Types::BaseObject
    field :exp, GraphQL::Types::ISO8601DateTime, null: true, description: 'The date and time when the current authentication will expire.'
    field :iat, GraphQL::Types::ISO8601DateTime, null: true, description: 'The date and time when the current authentication were issued.'
    field :iss, String, null: true, description: 'The issuer of the current authentication.'
    field :name, String, null: true, description: 'The name associated with the current authentication.'
    field :sub, Int, null: true, description: 'The subject of the current authentication.'
    field :user, Types::UserType, null: true, description: 'The current user associated with the current authentication.'

    def exp
      DateTime.strptime(context[:jwt]['exp'].to_s, '%s') if context.dig(:jwt,'exp')
    end

    def iat
      DateTime.strptime(context[:jwt]['iat'].to_s, '%s') if context.dig(:jwt,'iat')
    end

    def user
      context[:current_user]
    end
  end
end
