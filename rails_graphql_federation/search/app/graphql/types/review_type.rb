module Types
  class ReviewType < Types::BaseObject
    extend_type

    field :id, ID, null: false, external: true

    key fields: 'id'
  end
end
