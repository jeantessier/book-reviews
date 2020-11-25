module Types
  class BaseObject < GraphQL::Schema::Object
    include GraphQL::BatchLoaders::Helper
    include GraphQL::UserErrors::Helper

    field_class Types::BaseField

    def user_errors
      if object.present?
        object[:user_errors]
      else
        super
      end
    end
  end
end
