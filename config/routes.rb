Rails.application.routes.draw do
  resources :votes
  resources :scans
  resources :users
  root 'application#hello'
end
