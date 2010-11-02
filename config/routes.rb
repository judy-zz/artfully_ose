Artfully::Application.routes.draw do
  devise_for :users

  resources :tickets, :only => [:index, :show]
  resources :performances

  resources :orders

  root :to => "index#index"
end
