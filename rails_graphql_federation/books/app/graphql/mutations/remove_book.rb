module Mutations
  class RemoveBook < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false

    def resolve(id:)
      book = BookRepository.find_by_id(id)
      return { success: false } if book.nil?

      payload = {
        type: 'removeBook',
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
