module Types
  class QueryType < Types::BaseObject
    field :books,
      [Types::BookType],
      null: false,
      description: "Returns all the books in the system."

    field :book,
      Types::BookType,
      null: true,
      description: "Returns a specific book by its ID." do
      argument :book_id, ID, '', required: true
    end

    field :reviews,
      [Types::ReviewType],
      null: false,
      description: "Returns all the reviews in the system, or all reviews by a given reviewer."do
      argument :for_reviewer, ID, '', required: false
    end

    field :review,
      Types::ReviewType,
      null: true,
      description: "Returns a specific book by its ID." do
      argument :review_id, ID, '', required: true
    end

    field :users,
      [Types::UserType],
      null: false,
      description: "Returns all the users in the system."

    field :user,
      Types::UserType,
      null: true,
      description: "Returns a specific user by its ID." do
      argument :user_id, ID, '', required: true
    end

    field :me,
      Types::JwtType,
      null: false,
      description: "Returns the information about the currently logged in user"

    def books
      Book.all
    end

    def book(book_id:)
      Book.find_by(id: book_id)
    end

    def reviews(for_reviewer: nil)
      for_reviewer ? Review.where(reviewer_id: for_reviewer) : Review.all
    end

    def review(review_id:)
      Review.find_by(id: review_id)
    end

    def users
      User.all
    end

    def user(user_id:)
      User.find_by(id: user_id)
    end

    def me
      context[:jwt]
    end
  end
end
