Artfully::Application.routes.draw do
  devise_for :users
  resources :users, :only => [:show] do
    resources :roles
  end

  scope :module => :athena do
    resources :tickets, :only => [:index, :show]
  end

  resources :performances
  resources :orders

  root :to => "index#index"
end
