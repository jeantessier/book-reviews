module Types
  class MutationType < Types::BaseObject
    field :add_review, mutation: Mutations::AddReview
    field :update_review, mutation: Mutations::UpdateReview
    field :remove_review, mutation: Mutations::RemoveReview
  end
end
