module Types
  class BaseObject < GraphQL::Schema::Object
    include GraphQL::BatchLoaders::Helper

    field_class Types::BaseField
  end
end
