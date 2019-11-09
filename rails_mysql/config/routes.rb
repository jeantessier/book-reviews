Rails.application.routes.draw do
  post 'user_token' => 'user_token#create'
  devise_for :users
  resources :books do
    resources :book_authors, path: "authors"
    resources :book_years, path: "years"
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
