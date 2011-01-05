Artfully::Application.routes.draw do
  devise_for :users

  resources :user_roles
  resources :users, :only => [:show] do
    resources :credit_cards
    resources :user_roles
    resources :events


  end

  resources :tickets, :only => [:index]

  resources :orders
  resource :checkout
  resources :performances

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
  match '/performances/:id/createtickets/' => 'performances#createtickets', :as => :create_tickets_for_performance

  root :to => "index#index"
end
