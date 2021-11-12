class BookAndUserConsumer
  include Phobos::Handler
  include Phobos::Producer

  KAFKA_TOPIC = 'book-reviews.reviews'

  def consume(payload, metadata)
    Rails.logger.info "#{self.class.name} #{metadata[:topic]}[#{metadata[:partition]}] offset: #{metadata[:offset]}, headers: #{metadata[:headers]}, key: #{metadata[:key]}, value: #{payload}"

    json_message = JSON.parse(payload)
    message_type = json_message.delete('type')

    Rails.logger.info "#{message_type} #{json_message}"

    case message_type
    when 'bookRemoved'
      remove_book json_message
    when 'userRemoved'
      remove_user json_message
    else
      Rails.logger.info "Skipping ..."
    end
  end

  private

  def remove_book(json_message)
    remove_all ReviewRepository.find_all_by_book(json_message['id'])
  end

  def remove_user(json_message)
    remove_all ReviewRepository.find_all_by_reviewer(json_message['id'])
  end

  def remove_all(reviews)
    reviews.each do |review|
      payload = {
        type: 'reviewRemoved',
        id: review[:id],
      }.to_json

      Rails.logger.info <<-MSG
        Sending message ...
          topic: #{KAFKA_TOPIC}
          key: #{review[:id]}
          payload: #{payload}
      MSG

      producer.publish(
        topic: KAFKA_TOPIC,
        key: review[:id],
        payload: payload,
      )
    end
  end
end
