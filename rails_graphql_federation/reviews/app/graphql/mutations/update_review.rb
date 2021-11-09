module Mutations
  class UpdateReview < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :body, String, required: false
    argument :start, String, required: false
    argument :stop, String, required: false

    field :review, Types::ReviewType, null: true

    def resolve(id:, body: nil, start: nil, stop: nil)
      review = ReviewRepository.find_by_id(id)
      raise "No review with ID #{id}" if review.nil?

      review[:body] = body unless body.nil?
      review[:start] = start unless start.nil?
      review[:stop] = name unless stop.nil?

      { review: review }
    end
  end
end
