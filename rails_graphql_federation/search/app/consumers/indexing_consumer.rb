class IndexingConsumer
  include Phobos::Handler

  def consume(payload, metadata)
    Rails.logger.info "#{self.class.name} #{metadata[:topic]}[#{metadata[:partition]}] offset: #{metadata[:offset]}, headers: #{metadata[:headers]}, key: #{metadata[:key]}, value: #{payload}"

    json_message = JSON.parse(payload)
    message_type = json_message.delete('type')

    Rails.logger.info "#{message_type} #{json_message}"

    case message_type
    when 'bookAdded'
      SearchService.index_book json_message
    when 'bookUpdated'
      SearchService.index_book json_message
    when 'bookRemoved'
      SearchService.scrub_indices json_message
    when 'reviewAdded'
      SearchService.index_review json_message
    when 'reviewUpdated'
      SearchService.index_review json_message
    when 'reviewRemoved'
      SearchService.scrub_indices json_message
    when 'userAdded'
      SearchService.index_user json_message
    when 'userUpdated'
      SearchService.index_user json_message
    when 'userRemoved'
      SearchService.scrub_indices json_message
    else
      Rails.logger.info "Skipping ..."
    end

    # SearchService.log_indices
  end
end
