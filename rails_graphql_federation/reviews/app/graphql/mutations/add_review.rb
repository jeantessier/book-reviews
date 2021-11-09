module Mutations
  class AddReview < Mutations::BaseMutation
    argument :reviewer_id, ID, required: true
    argument :book_id, ID, required: true
    argument :body, String, required: true
    argument :start, String, required: false
    argument :stop, String, required: false

    field :review, Types::ReviewType, null: true

    def resolve(reviewer_id:, book_id:, body:, start: nil, stop: nil)
      review = {
        id: SecureRandom.uuid,
        reviewer: {
          __typename: 'User',
          id: reviewer_id,
        },
        book: {
          __typename: 'Book',
          id: book_id,
        },
        body: body,
        start: start,
        stop: stop,
      }

      ReviewRepository.save(review)

      { review: review }
    end
  end
end
