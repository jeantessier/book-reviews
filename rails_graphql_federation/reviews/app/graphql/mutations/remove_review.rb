module Mutations
  class RemoveReview < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false

    def ready?(id:)
      review = ReviewRepository.find_by_id(id)
      raise "No review with ID #{id}" if review.nil?

      raise 'You need to be signed in to use this mutation.' if context[:current_user].nil?
      raise 'You need to have admin privileges to use this mutation on behalf of another user.' unless context[:current_user][:sub] == review[:reviewer][:id] || context[:current_user][:roles]&.include?('ROLE_ADMIN')

      true
    end

    def resolve(id:)
      review = ReviewRepository.find_by_id(id)
      return { success: false } if review.nil?

      payload = {
        type: 'reviewRemoved',
        id: id,
      }.to_json

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

      { success: true }
    end
  end
end
