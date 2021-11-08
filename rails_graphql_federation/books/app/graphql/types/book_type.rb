module Types
  class BookType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, 'A unique value that identifies this book.  Good for human-readable permalinks.', null: false
    field :title, String, 'A shortcut to the first title in titles.', null: false
    field :titles, [Types::TitleType], 'A list of titles by which this book is known.  Some may contain HTML markup.', null: false
    field :authors, [String], 'A list of authors of this book.', null: false
    field :years, [String], 'Years of publication, including re-editions and translations.', null: false
    field :publisher, String, null: false

    key fields: 'id'
  end
end
