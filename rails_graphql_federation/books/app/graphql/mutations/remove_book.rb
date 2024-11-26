module Mutations
  class RemoveBook < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false

    def ready?(id:)
      raise "You need to be signed in to use this mutation." if context[:current_user].nil?
      raise "You need to have admin privileges to use this mutation." unless context[:current_user][:roles]&.include?("ROLE_ADMIN")

      true
    end

    def resolve(id:)
      book = BookRepository.find_by_id(id)
      return { success: false } if book.nil?

      payload = {
        type: "bookRemoved",
        id:,
      }.to_json

      headers = {
        current_user: context[:current_user][:sub],
        request_id: context[:request_id],
      }

      Rails.logger.info <<-MSG
        Sending message ...
          topic: #{KAFKA_TOPIC}
          headers: #{headers}
          key: #{id}
          payload: #{payload}
      MSG

      producer.publish(
        topic: KAFKA_TOPIC,
        headers:,
        key: id,
        payload:,
      )

      { success: true }
    end
  end
end
