Artfully::Application.routes.draw do
  devise_for :users

  resources :user_roles
  resources :users, :only => [:show] do
    resources :credit_cards
    resources :user_roles
  end

  resources :tickets, :only => [:index, :show]

  resources :orders

  root :to => "index#index"
end
