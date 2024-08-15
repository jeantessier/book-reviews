class UserConsumer
  include Phobos::Handler

  def consume(payload, metadata)
    Rails.logger.info "#{self.class.name} #{metadata[:topic]}[#{metadata[:partition]}] offset: #{metadata[:offset]}, headers: #{metadata[:headers]}, key: #{metadata[:key]}, value: #{payload}"

    json_message = JSON.parse(payload)
    message_type = json_message.delete("type")

    Rails.logger.info "#{message_type} #{json_message}"

    case message_type
    when "userAdded"
      add_user json_message
    when "userUpdated"
      update_user json_message
    when "userRemoved"
      remove_user json_message
    else
      Rails.logger.info "Skipping ..."
    end
  end

  private

  def add_user(json_message)
    user = {
      id: json_message["id"],
      name: json_message["name"],
      email: json_message["email"],
      password: json_message["password"],
      roles: json_message["roles"],
    }

    UserRepository.save(user)
  end

  def update_user(json_message)
    user = UserRepository.find_by_id(json_message["id"])
    raise "No user with ID #{json_message['id']}" if user.nil?

    user[:name] = json_message["name"] if json_message.include?("name")
    user[:email] = json_message["email"] if json_message.include?("email")
    user[:password] = json_message["password"] if json_message.include?("password")
    user[:roles] = json_message["roles"] if json_message.include?("roles")
  end

  def remove_user(json_message)
    UserRepository.remove(json_message["id"])
  end
end
