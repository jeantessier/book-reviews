module Types
  class UserType < Types::BaseObject
    extend_type

    field :id, ID, null: false, external: true
    field :name, String, null: false, external: true
    field :email, String, null: false, external: true
    field :signature, String, 'an elegant custom signature', null: false, requires: { fields: "name email"}

    key fields: 'id'

    def signature
      "-- #{object[:name]} <#{object[:email]}>"
    end
  end
end
