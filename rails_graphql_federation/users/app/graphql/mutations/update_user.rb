module Mutations
  class UpdateUser < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :email, String, required: false
    argument :password, String, required: false
    argument :roles, [ String ], required: false

    field :user, Types::UserType, null: true

    def ready?(id:, name: nil, email: nil, password: nil, roles: nil)
      raise "You need to be signed in to use this mutation." if context[:current_user].nil?
      raise "You need to have admin privileges to use this mutation on another user." unless context[:current_user][:sub] == id || context[:current_user][:roles]&.include?("ROLE_ADMIN")
      raise "You need to have admin privileges to change roles on a user." unless roles.nil? || context[:current_user][:roles]&.include?("ROLE_ADMIN")

      true
    end

    def resolve(id:, name: nil, email: nil, password: nil, roles: nil)
      user = UserRepository.find_by_id(id).dup
      raise "No user with ID #{id}" if user.nil?

      user_by_email = UserRepository.find_by_email(email)
      raise "Email \"#{email}\" is already taken" unless user_by_email == user || user_by_email.nil?

      user[:name] = name unless name.nil?
      user[:email] = email unless email.nil?
      user[:password] = password unless password.nil?
      user[:roles] = roles unless roles.nil?

      payload = { type: "userUpdated" }.merge(user).to_json

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
        headers: headers,
        key: id,
        payload: payload,
      )

      { user: user }
    end
  end
end
