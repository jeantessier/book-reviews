module Mutations
  class AddBook < Mutations::BaseMutation
    argument :name, String, required: true
    argument :titles, [ Types::TitleInput ], required: true
    argument :authors, [ String ], required: true
    argument :publisher, String, required: true
    argument :years, [ String ], required: true

    field :book, Types::BookType, null: true

    def ready?(name:, titles:, authors:, publisher:, years:)
      raise "You need to be signed in to use this mutation." if context[:current_user].nil?
      raise "You need to have admin privileges to use this mutation." unless context[:current_user][:roles]&.include?("ROLE_ADMIN")

      true
    end

    def resolve(name:, titles:, authors:, publisher:, years:)
      raise "Duplicate name \"#{name}\"" unless BookRepository.find_by_name(name).nil?

      book = {
        id: SecureRandom.uuid,
        name:,
        titles:,
        authors:,
        publisher:,
        years:,
      }

      payload = { type: "bookAdded" }.merge(book).to_json

      headers = {
        current_user: context[:current_user][:sub],
        request_id: context[:request_id],
      }

      Rails.logger.info <<-MSG
        Sending message ...
          topic: #{KAFKA_TOPIC}
          headers: #{headers}
          key: #{book[:id]}
          payload: #{payload}
      MSG

      producer.publish(
        topic: KAFKA_TOPIC,
        headers:,
        key: book[:id],
        payload:,
      )

      { book: }
    end
  end
end
