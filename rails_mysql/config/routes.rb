Rails.application.routes.draw do
  # Override Devise's default routes: /users/sign_in, etc.
  devise_for :users,
             path: '',
             path_names: {
                 sign_in: 'login',
                 sign_out: 'logout',
                 registration: 'signup'
             },
             controllers: {
                 sessions: 'sessions',
                 registrations: 'registrations'
             }
  resources :books
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
