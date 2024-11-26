module Mutations
  class SignUp < Mutations::BaseMutation
    argument :name, String, required: true
    argument :email, String, required: true
    argument :password, String, required: true

    field :user, Types::UserType, null: true

    def resolve(name:, email:, password:)
      raise "Duplicate email \"#{email}\"" unless UserRepository.find_by_email(email).nil?

      user = {
        id: SecureRandom.uuid,
        name:,
        email:,
        password:,
        roles: [ "ROLE_USER" ],
      }

      payload = { type: "userAdded" }.merge(user).to_json

      headers = {
        current_user: user[:id],
        request_id: context[:request_id],
      }

      Rails.logger.info <<-MSG
        Sending message ...
          topic: #{KAFKA_TOPIC}
          headers: #{headers}
          key: #{user[:id]}
          payload: #{payload}
      MSG

      producer.publish(
        topic: KAFKA_TOPIC,
        headers:,
        key: user[:id],
        payload:,
      )

      { user: }
    end
  end
end
