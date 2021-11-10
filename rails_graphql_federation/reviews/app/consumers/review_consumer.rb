class ReviewConsumer
  include Phobos::Handler

  def consume(payload, metadata)
    Rails.logger.info "#{self.class.name} #{metadata[:topic]}[#{metadata[:partition]}] offset: #{metadata[:offset]}, headers: #{metadata[:headers]}, key: #{metadata[:key]}, value: #{payload}"

    json_message = JSON.parse(payload)
    message_type = json_message.delete('type')

    Rails.logger.info "#{message_type} #{json_message}"

    case message_type
    when 'addReview'
      add_review json_message
    when 'updateReview'
      update_review json_message
    when 'removeReview'
      remove_review json_message
    else
      Rails.logger.info "Skipping ..."
    end
  end

  private

  def add_review(json_message)
    review = {
      id: json_message['id'],
      reviewer: json_message['reviewer'].transform_keys(&:to_sym),
      book: json_message['book'].transform_keys(&:to_sym),
      body: json_message['body'],
      start: json_message['start'],
      stop: json_message['stop'],
    }

    ReviewRepository.save(review)
  end

  def update_review(json_message)
    review = ReviewRepository.find_by_id(json_message['id'])
    raise "No review with ID #{json_message['id']}" if review.nil?

    review[:body] = json_message['body'] if json_message.include?('body')
    review[:start] = json_message['start'] if json_message.include?('start')
    review[:stop] = json_message['stop'] if json_message.include?('stop')
  end

  def remove_review(json_message)
    ReviewRepository.remove(json_message['id'])
  end
end
