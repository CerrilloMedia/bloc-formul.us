Rails.application.routes.draw do

  devise_for :users
  
  resources :users, only: [:index, :show, :edit]
  resources :salon_connections, only: [:create, :destroy]
  
  root 'welcome#index'
end
