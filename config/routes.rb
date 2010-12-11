Artfully::Application.routes.draw do
  devise_for :users

  resources :user_roles
  resources :users, :only => [:show] do
    resources :credit_cards
    resources :user_roles
    resources :events
  

  end

  resources :tickets, :only => [:index, :show]

  resources :orders
  resources :events do
    resources :performances
  end

  resources :charts do
    resources :sections
  end

  namespace :admin do
    root :to => "index#index"
    resources :users
  end

  match '/performances/:id/duplicate/' => 'performances#duplicate', :as => :duplicate_performance
  match '/events/:event_id/charts/duplicate/' => 'charts#duplicate', :as => :duplicate_chart

  root :to => "index#index"
end
