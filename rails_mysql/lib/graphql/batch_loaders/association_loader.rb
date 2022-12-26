module GraphQL
  module BatchLoaders
    # Taken from the examples in Shopify's graphql-batch gem.
    # https://github.com/Shopify/graphql-batch/blob/master/examples/association_loader.rb
    class AssociationLoader < GraphQL::Batch::Loader
      def self.validate(model, associations)
        new(model, associations)
        nil
      end

      def initialize(model, associations)
        @model = model
        @associations = associations
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
        ::ActiveRecord::Associations::Preloader.new(records: records, associations: @associations).call
      end
    end
  end
end
