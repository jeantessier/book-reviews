module GraphQL
  module BatchLoaders
    # Taken from the examples in Shopify's graphql-batch gem.
    # https://github.com/Shopify/graphql-batch/blob/master/examples/association_loader.rb
    class AssociationLoader < GraphQL::Batch::Loader
      def self.validate(model, association_name)
        new(model, association_name)
        nil
      end

      def initialize(model, association_name)
        @model = model
        @association_name = association_name
      end

      def load(record)
        raise TypeError, "#{@model} loader can't load association for #{record.class}" unless record.is_a?(@model)
        super
      end

      # We want to load the associations on all records, even if they have the same id
      def cache_key(record)
        record.object_id
      end

      def perform(records)
        preload_association(records)
        records.each { |record| fulfill(record, record) }
      end

      private

      def preload_association(records)
        ::ActiveRecord::Associations::Preloader.new.preload(records, @association_name)
      end
    end
  end
end
