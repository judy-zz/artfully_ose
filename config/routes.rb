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
  match '/events/:event_id/charts/assign/' => 'charts#assign', :as => :assign_chart
  match '/performances/:id/createtickets/' => 'performances#createtickets', :as => :create_tickets_for_performance
  match '/performances/:id/put_on_sale/' => 'performances#put_on_sale', :as => :put_performance_on_sale
  match '/performances/:id/take_off_sale/' => 'performances#take_off_sale', :as => :take_performance_off_sale
  match '/performances/:performance_id/tickets/bulk_edit' => 'tickets#bulk_edit', :as => :bulk_edit_performance_tickets

  root :to => "index#index"
end
