module Mutations
  class AddBook < Mutations::BaseMutation
    argument :name, String, required: true
    argument :titles, [Types::TitleInput], required: true
    argument :authors, [String], required: true
    argument :publisher, String, required: true
    argument :years, [String], required: true

    field :book, Types::BookType, null: true

    def resolve(name:, titles:, authors:, publisher:, years:)
      raise "Duplicate name \"#{name}\"" unless BookRepository.find_by_name(name).nil?

      book = {
        id: SecureRandom.uuid,
        name: name,
        titles: titles,
        authors: authors,
        publisher: publisher,
        years: years,
      }

      BookRepository.save(book)

      { book: book }
    end
  end
end
