module Types
  class TitleType < Types::BaseObject
    description "A title for a book, or an alternative, often a translation."

    field :title, String, "The title for a book.  May include HTML markup.", null: false
    field :link, String, "An optional hyperlink pointing to further information about the book.", null: true
  end
end
