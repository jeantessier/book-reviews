module Mutations
  class RemoveUser < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false

    def resolve(id:)
      user = UserRepository.find_by_id(id)
      return { success: false } if user.nil?

      payload = {
        type: 'userRemoved',
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
