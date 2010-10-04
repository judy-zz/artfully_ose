ArtfulLy::Application.routes.draw do
  devise_for :users
  resources :tickets

  root :to => "index#index"
end
