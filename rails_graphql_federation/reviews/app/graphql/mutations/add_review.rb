module Mutations
  class AddReview < Mutations::BaseMutation
    argument :reviewer_id, ID, required: false
    argument :book_id, ID, required: true
    argument :body, String, required: true
    argument :start, String, required: false
    argument :stop, String, required: false

    field :review, Types::ReviewType, null: true

    def ready?(reviewer_id: nil, book_id:, body:, start: nil, stop: nil)
      raise "You need to be signed in to use this mutation." if context[:current_user].nil?

      Rails.logger.info "*****   context[:current_user]: #{context[:current_user]}"
      Rails.logger.info "*****   context[:current_user][:sub]: #{context[:current_user][:sub]}"
      Rails.logger.info "*****   reviewer_id: #{reviewer_id}"
      Rails.logger.info "*****   context[:current_user][:sub] == reviewer_id: #{context[:current_user][:sub] == reviewer_id}"

      raise "You need to have admin privileges to use this mutation on behalf of another user." unless reviewer_id.nil? || context[:current_user][:sub] == reviewer_id || context[:current_user][:roles]&.include?("ROLE_ADMIN")

      true
    end

    # const { reviewerId, bookId, ...reviewAddedMessage } = review
    # if (reviewerId && reviewerId !== context.currentUser.id && !context.currentUser.roles?.includes('ROLE_ADMIN')) {
    #   throw new ForbiddenError(`You need to have admin privileges to use the ${info.fieldName} mutation on behalf of another user.`)
    # }

    def resolve(reviewer_id: nil, book_id:, body:, start: nil, stop: nil)
      reviewer_id = context[:current_user][:sub] if reviewer_id.nil?

      review = {
        id: SecureRandom.uuid,
        reviewer: {
          __typename: "User",
          id: reviewer_id,
        },
        book: {
          __typename: "Book",
          id: book_id,
        },
        body: body,
        start: start,
        stop: stop,
      }

      payload = { type: "reviewAdded" }.merge(review).to_json

      headers = {
        current_user: context[:current_user][:sub],
        request_id: context[:request_id],
      }

      Rails.logger.info <<-MSG
        Sending message ...
          topic: #{KAFKA_TOPIC}
          headers: #{headers}
          key: #{review[:id]}
          payload: #{payload}
      MSG

      producer.publish(
        topic: KAFKA_TOPIC,
        headers: headers,
        key: review[:id],
        payload: payload,
      )

      { review: review }
    end
  end
end
