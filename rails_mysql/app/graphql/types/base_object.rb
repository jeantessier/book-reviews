module Types
  class BaseObject < GraphQL::Schema::Object
    field_class Types::BaseField

    protected

    def load_association(association_name)
      GraphQL::BatchLoaders::AssociationLoader.for(object.class, association_name).load(object)
    end
  end
end
