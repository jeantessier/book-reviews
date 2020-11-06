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
      GraphQL::BatchLoaders::AssociationLoader.for(Book, :titles).load(object).then do
        object.titles
      end
    end

    def authors
      GraphQL::BatchLoaders::AssociationLoader.for(Book, :authors).load(object).then do
        object.authors.collect {|ba| ba.author}
      end
    end

    def years
      GraphQL::BatchLoaders::AssociationLoader.for(Book, :years).load(object).then do
        object.years.collect {|by| by.year}
      end
    end

    def reviews
      GraphQL::BatchLoaders::AssociationLoader.for(Book, :reviews).load(object).then do
        object.reviews
      end
    end

    def reviewers
      GraphQL::BatchLoaders::AssociationLoader.for(Book, :reviewers).load(object).then do
        object.reviewers
      end
    end
  end
end
