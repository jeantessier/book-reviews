module Types
  class BookType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, 'A unique value that identifies this book.  Good for human-readable permalinks.', null: false
    field :titles, [Types::TitleType], 'A list of titles by which this book is known.  Some may contain HTML markup.', null: false
    field :authors, [String], 'A list of authors of this book.', null: false
    field :years, [String], 'Years of publication, including re-editions and translations.', null: false
    field :publisher, String, null: false
    field :reviews, [Types::ReviewType], null: false
    field :reviewers, [Types::UserType], null: false

    def titles
      load_association(:titles).then(&:titles)
    end

    def authors
      load_association(:authors).then do
        object.authors.collect {|ba| ba.author}
      end
    end

    def years
      load_association(:years).then do
        object.years.collect {|by| by.year}
      end
    end

    def reviews
      load_association(:reviews).then(&:reviews)
    end

    def reviewers
      load_association(:reviewers).then(&:reviewers)
    end
  end
end
