module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :name, String, null: false
    field :reviews, [Types::ReviewType], null: false
    field :books, [Types::BookType], null: false
    field :signature, String, null: false

    def reviews
      load_association(:reviews).then(&:reviews)
    end

    def books
      load_association(:books).then(&:books)
    end

    def signature
      "-- #{object.name} <#{object.email}>"
    end
  end
end
