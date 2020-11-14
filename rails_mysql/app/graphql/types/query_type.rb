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
      argument :book_id, ID, required: true
    end

    field :reviews,
      [Types::ReviewType],
      null: false,
      description: "Returns all the reviews in the system, or all reviews by a given reviewer."do
      argument :for_reviewer, ID, required: false
    end

    field :review,
      Types::ReviewType,
      null: true,
      description: "Returns a specific book by its ID." do
      argument :review_id, ID, required: true
    end

    field :users,
      [Types::UserType],
      null: false,
      description: "Returns all the users in the system."

    field :user,
      Types::UserType,
      null: true,
      description: "Returns a specific user by its ID." do
      argument :user_id, ID, required: true
    end

    field :me,
      Types::JwtType,
      null: false,
      description: "Returns the information about the currently logged in user"

    field :search,
      [Types::SearchResultUnion],
      null: false,
      description: "Returns books, reviews, and/or users that match a query" do
      argument :q, String, required: true
    end

    def books
      Book.all
    end

    def book(book_id:)
      GraphQL::BatchLoaders::RecordLoader.for(Book).load(book_id)
    end

    def reviews(for_reviewer: nil)
      for_reviewer ? Review.where(reviewer_id: for_reviewer) : Review.all
    end

    def review(review_id:)
      GraphQL::BatchLoaders::RecordLoader.for(Review).load(review_id)
    end

    def users
      User.all
    end

    def user(user_id:)
      GraphQL::BatchLoaders::RecordLoader.for(User).load(user_id)
    end

    def me
      context[:jwt]
    end

    def search(q:)
      results = []
      results += Book.where(id: search_books(q))
      results += Review.where(id: search_reviews(q))
      results += User.where(id: search_users(q))
      results
    end

    private

    def search_books(q)
      results = Set.new
      results += Book.where('publisher LIKE :q', {q: "%#{q}%"}).pluck(:id)
      results += BookTitle.where('title LIKE :q OR link LIKE :q', {q: "%#{q}%"}).pluck(:book_id)
      results += BookAuthor.where('author LIKE :q', {q: "%#{q}%"}).pluck(:book_id)
      results += BookYear.where('year LIKE :q', {q: "%#{q}%"}).pluck(:book_id)
      results.to_a
    end

    def search_reviews(q)
      Review.where('body LIKE :q OR start LIKE :q OR stop LIKE :q', {q: "%#{q}%"}).pluck(:id)
    end

    def search_users(q)
      User.where('name LIKE :q OR email LIKE :q', {q: "%#{q}%"}).pluck(:id)
    end
  end
end
