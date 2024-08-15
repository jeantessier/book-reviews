module GraphQL
  module BatchLoaders
    module Helper
      def load_association(association_name)
        AssociationLoader.for(object.class, association_name).load(object)
      end
    end
  end
end
