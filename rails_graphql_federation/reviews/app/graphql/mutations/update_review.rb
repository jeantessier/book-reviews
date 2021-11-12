module Mutations
  class UpdateReview < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :body, String, required: false
    argument :start, String, required: false
    argument :stop, String, required: false

    field :review, Types::ReviewType, null: true

    def ready?(id:, body: nil, start: nil, stop: nil)
      review = ReviewRepository.find_by_id(id)
      raise "No review with ID #{id}" if review.nil?

      raise 'You need to be signed in to use this mutation.' if context[:current_user].nil?
      raise 'You need to have admin privileges to use this mutation on behalf of another user.' unless context[:current_user][:sub] == review[:reviewer][:id] || context[:current_user][:roles]&.include?('ROLE_ADMIN')

      true
    end

    def resolve(id:, body: nil, start: nil, stop: nil)
      review = ReviewRepository.find_by_id(id).dup
      raise "No review with ID #{id}" if review.nil?

      review[:body] = body unless body.nil?
      review[:start] = start unless start.nil?
      review[:stop] = stop unless stop.nil?

      payload = { type: 'reviewUpdated' }.merge(review).to_json

      Rails.logger.info <<-MSG
        Sending message ...
          topic: #{KAFKA_TOPIC}
          key: #{id}
          payload: #{payload}
      MSG

      producer.publish(
        topic: KAFKA_TOPIC,
        key: id,
        payload: payload,
      )

      { review: review }
    end
  end
end
