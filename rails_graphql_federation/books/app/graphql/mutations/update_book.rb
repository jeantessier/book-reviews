module Mutations
  class UpdateBook < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :titles, [Types::TitleInput], required: false
    argument :authors, [String], required: false
    argument :publisher, String, required: false
    argument :years, [String], required: false

    field :book, Types::BookType, null: true

    def resolve(id:, name: nil, titles: nil, authors: nil, publisher: nil, years: nil)
      book = BookRepository.find_by_id(id).dup
      raise "No book with ID #{id}" if book.nil?

      book_by_name = BookRepository.find_by_name(name)
      raise "Name \"#{name}\" is already taken" unless book_by_name == book || book_by_name.nil?

      book[:name] = name unless name.nil?
      book[:titles] = titles unless titles.nil?
      book[:authors] = authors unless authors.nil?
      book[:publisher] = publisher unless publisher.nil?
      book[:years] = years unless years.nil?

      payload = { type: 'updateBook' }.merge(book).to_json

      Rails.logger.info <<-MSG
        Sending message ...
          topic: #{KAFKA_TOPIC}
          key: #{id}
          payload: #{payload}
      MSG

      producer.publish(
        topic: KAFKA_TOPIC,
        key: id,
        payload: payload,
      )

      { book: book }
    end
  end
end
