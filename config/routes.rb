Rails.application.routes.draw do

  devise_for :users
  
  resources :users, only: [:index, :show, :edit] do
    resources :formulas, only: [:index]
  end
  resources :salon_connections, only: [:create, :destroy]
  resources :formulas, except: [:index]
  
  root 'welcome#index'
end
