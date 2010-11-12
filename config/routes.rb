Artfully::Application.routes.draw do
  devise_for :users

  resources :user_roles
  resources :users, :only => [:show] do
    resources :user_roles
  end

  scope :module => :athena do
    resources :tickets, :only => [:index, :show]
  end

  resources :performances
  resources :orders

  root :to => "index#index"
end
