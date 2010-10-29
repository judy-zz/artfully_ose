Artfully::Application.routes.draw do
  devise_for :users

  resources :tickets, :only => [:index, :show]
  resources :performances
  resources :transactions, :only => [:create, :show, :destroy]
  resources :payments, :only => [:create, :show, :destroy]

  resources :orders

  root :to => "index#index"
end
