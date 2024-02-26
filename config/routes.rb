Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  scope module: :web do
    root 'welcome#index'

    post '/auth/:provider', to: 'auth#request', as: :auth_request
    get '/auth/:provider/callback', to: 'auth#callback', as: :callback_auth
    delete '/auth', to: 'auth#destroy', as: :destroy_user_session

    resources :repositories
  end
end
