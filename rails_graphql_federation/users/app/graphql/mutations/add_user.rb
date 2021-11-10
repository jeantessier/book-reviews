module Mutations
  class AddUser < Mutations::BaseMutation
    argument :name, String, required: true
    argument :email, String, required: true
    argument :password, String, required: true
    argument :roles, [String], required: true

    field :user, Types::UserType, null: true

    def resolve(name:, email:, password:, roles:)
      raise "Duplicate email \"#{email}\"" unless UserRepository.find_by_email(email).nil?

      user = {
        id: SecureRandom.uuid,
        name: name,
        email: email,
        password: password,
        roles: roles,
      }

      payload = { type: 'addUser' }.merge(user).to_json

      Rails.logger.info <<-MSG
        Sending message ...
          topic: #{KAFKA_TOPIC}
          key: #{user[:id]}
          payload: #{payload}
      MSG

      producer.publish(
        topic: KAFKA_TOPIC,
        key: user[:id],
        payload: payload,
      )

      { user: user }
    end
  end
end
