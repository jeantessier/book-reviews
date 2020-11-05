module Types
  class BookType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :titles, [Types::TitleType], null: false
    field :authors, [String], null: false
    field :years, [String], null: false
    field :publisher, String, null: false
    field :reviews, [Types::ReviewType], null: false
    field :reviewers, [Types::UserType], null: false

    def authors
      object.authors.collect {|ba| ba.author}
    end

    def years
      object.years.collect {|by| by.year}
    end
  end
end
