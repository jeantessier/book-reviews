Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql" if Rails.env.development?
  post "/graphql", to: "graphql#execute"
  devise_for :users
  resources :books do
    resources :book_authors, path: "authors"
    resources :book_years, path: "years"
    resources :book_titles, path: "titles"
    resources :book_reviews, path: "reviews"
  end
  resources :reviews
  get "users/:id" => "users#show"
  get "users/:user_id/reviews" => "user_reviews#index"
  get "users/:user_id/reviews/:id" => "user_reviews#show"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
