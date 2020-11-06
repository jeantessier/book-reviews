module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :name, String, null: false
    field :reviews, [Types::ReviewType], null: false
    field :books, [Types::BookType], null: false

    def reviews
      GraphQL::BatchLoaders::AssociationLoader.for(User, :reviews).load(object).then do
        object.reviews
      end
    end

    def books
      GraphQL::BatchLoaders::AssociationLoader.for(User, :books).load(object).then do
        object.books
      end
    end
  end
end
