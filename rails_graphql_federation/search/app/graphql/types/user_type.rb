module Types
  class UserType < Types::BaseObject
    extend_type

    field :id, ID, null: false, external: true

    key fields: "id"
  end
end
