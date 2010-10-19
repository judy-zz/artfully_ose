Artfully::Application.routes.draw do
  devise_for :users

  resources :tickets, :only => [:index, :show]
  resources :performances
  resources :transactions, :only => [:create, :show]

  root :to => "index#index"
end
