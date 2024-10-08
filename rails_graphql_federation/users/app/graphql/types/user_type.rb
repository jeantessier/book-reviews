module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :email, String, null: false
    field :roles, [ String ], null: false

    key fields: "id"

    def self.resolve_reference(reference, _context)
      UserRepository.find_by_id(reference[:id])
    end
  end
end
