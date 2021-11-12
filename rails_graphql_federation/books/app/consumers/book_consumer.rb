class BookConsumer
  include Phobos::Handler

  def consume(payload, metadata)
    Rails.logger.info "#{self.class.name} #{metadata[:topic]}[#{metadata[:partition]}] offset: #{metadata[:offset]}, headers: #{metadata[:headers]}, key: #{metadata[:key]}, value: #{payload}"

    json_message = JSON.parse(payload)
    message_type = json_message.delete('type')

    Rails.logger.info "#{message_type} #{json_message}"

    case message_type
    when 'bookAdded'
      add_book json_message
    when 'bookUpdated'
      update_book json_message
    when 'bookRemoved'
      remove_book json_message
    else
      Rails.logger.info "Skipping ..."
    end
  end

  private

  def add_book(json_message)
    book = {
      id: json_message['id'],
      name: json_message['name'],
      titles: json_message['titles'].collect { |title| title.transform_keys(&:to_sym) },
      authors: json_message['authors'],
      publisher: json_message['publisher'],
      years: json_message['years'],
    }

    BookRepository.save(book)
  end

  def update_book(json_message)
    book = BookRepository.find_by_id(json_message['id'])
    raise "No book with ID #{json_message['id']}" if book.nil?

    book[:name] = json_message['name'] if json_message.include?('name')
    book[:titles] = json_message['titles'] if json_message.include?('titles')
    book[:authors] = json_message['authors'] if json_message.include?('authors')
    book[:publisher] = json_message['publisher'].collect { |title| title.transform_keys(&:to_sym) } if json_message.include?('publisher')
    book[:years] = json_message['years'] if json_message.include?('years')
  end

  def remove_book(json_message)
    BookRepository.remove(json_message['id'])
  end
end
