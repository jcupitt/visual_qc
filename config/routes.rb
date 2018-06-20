Rails.application.routes.draw do
  resources :votes
  resources :scans
  resources :users
  root 'scans#index'

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
end
