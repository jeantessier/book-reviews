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

      payload = { type: 'reviewAdded' }.merge(review).to_json

      Rails.logger.info <<-MSG
        Sending message ...
          topic: #{KAFKA_TOPIC}
          key: #{review[:id]}
          payload: #{payload}
      MSG

      producer.publish(
        topic: KAFKA_TOPIC,
        key: review[:id],
        payload: payload,
      )

      { review: review }
    end
  end
end
