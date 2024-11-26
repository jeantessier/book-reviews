module Mutations
  class AddUser < Mutations::BaseMutation
    argument :name, String, required: true
    argument :email, String, required: true
    argument :password, String, required: true
    argument :roles, [ String ], required: true

    field :user, Types::UserType, null: true

    def ready?(name:, email:, password:, roles:)
      raise "You need to be signed in to use this mutation." if context[:current_user].nil?
      raise "You need to have admin privileges to use this mutation." unless context[:current_user][:roles]&.include?("ROLE_ADMIN")

      true
    end

    def resolve(name:, email:, password:, roles:)
      raise "Duplicate email \"#{email}\"" unless UserRepository.find_by_email(email).nil?

      user = {
        id: SecureRandom.uuid,
        name:,
        email:,
        password:,
        roles:,
      }

      payload = { type: "userAdded" }.merge(user).to_json

      headers = {
        current_user: context[:current_user][:sub],
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
