module Mutations
  class RemoveReview < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false

    def resolve(id:)
      { success: ReviewRepository.remove(id) }
    end
  end
end
