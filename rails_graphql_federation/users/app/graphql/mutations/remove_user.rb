module Mutations
  class RemoveUser < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false

    def resolve(id:)
      { success: UserRepository.remove(id) }
    end
  end
end
