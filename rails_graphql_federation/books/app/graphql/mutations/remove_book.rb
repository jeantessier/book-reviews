module Mutations
  class RemoveBook < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false

    def resolve(id:)
      { success: BookRepository.remove(id) }
    end
  end
end
