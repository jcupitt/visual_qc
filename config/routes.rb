Rails.application.routes.draw do
  get 'static_pages/help'
  get 'static_pages/results'

  resources :votes
  resources :scans
  resources :users
  root 'scans#index'

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
end
