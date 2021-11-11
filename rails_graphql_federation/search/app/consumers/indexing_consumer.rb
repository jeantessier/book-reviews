class IndexingConsumer
  include Phobos::Handler

  def consume(payload, metadata)
    Rails.logger.info "#{self.class.name} #{metadata[:topic]}[#{metadata[:partition]}] offset: #{metadata[:offset]}, headers: #{metadata[:headers]}, key: #{metadata[:key]}, value: #{payload}"

    json_message = JSON.parse(payload)
    message_type = json_message.delete('type')

    Rails.logger.info "#{message_type} #{json_message}"

    case message_type
    when 'addBook'
      SearchService.index_book json_message
    when 'updateBook'
      SearchService.index_book json_message
    when 'removeBook'
      SearchService.scrub_indices json_message
    when 'addReview'
      SearchService.index_review json_message
    when 'updateReview'
      SearchService.index_review json_message
    when 'removeReview'
      SearchService.scrub_indices json_message
    when 'addUser'
      SearchService.index_user json_message
    when 'updateUser'
      SearchService.index_user json_message
    when 'removeUser'
      SearchService.scrub_indices json_message
    else
      Rails.logger.info "Skipping ..."
    end
  end
end
