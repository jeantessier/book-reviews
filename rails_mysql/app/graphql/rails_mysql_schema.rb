require "graphql/batch_loaders"
require "graphql/user_errors"

class RailsMysqlSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  use GraphQL::Batch
end
