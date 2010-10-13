Artfully::Application.routes.draw do
  devise_for :users
  resources :tickets

  resources :performances

  root :to => "index#index"
end
