Artfully::Application.routes.draw do
  devise_for :users

  scope :module => :athena do
    resources :tickets, :only => [:index, :show]
  end

  resources :performances
  resources :orders

  root :to => "index#index"
end
