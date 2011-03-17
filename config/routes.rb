Artfully::Application.routes.draw do

  scope :module => :api do
    constraints :subdomain => "api" do
      resources :events, :only => :show
      resources :tickets, :only => :index
    end
  end

  namespace :store do
    resources :events, :only => :show
    resource :order, :only => [:show, :create, :update, :destroy ]
    resource :checkout
  end

  namespace :admin do
    root :to => "index#index"
    resources :users
    resources :organizations do
      resources :kits do
        put :activate, :on => :member
      end
      resources :memberships
    end
  end

  devise_for :users

  resources :organizations
  resources :kits
  resources :credit_cards, :except => :show

  resources :people, :only => [:index, :show, :edit, :update]
  resources :performances do
    get :door_list, :on => :member
  end

  resources :events do
    resources :performances
  end

  resources :charts do
    resources :sections
  end

  match '/performances/:id/duplicate/' => 'performances#duplicate', :as => :duplicate_performance
  match '/events/:event_id/charts/assign/' => 'charts#assign', :as => :assign_chart
  match '/performances/:id/createtickets/' => 'performances#createtickets', :as => :create_tickets_for_performance
  match '/performances/:id/put_on_sale/' => 'performances#put_on_sale', :as => :put_performance_on_sale
  match '/performances/:id/take_off_sale/' => 'performances#take_off_sale', :as => :take_performance_off_sale
  match '/performances/:performance_id/tickets/bulk_edit' => 'tickets#bulk_edit', :as => :bulk_edit_performance_tickets
  match '/performances/:performance_id/tickets/comp_ticket_details' => 'tickets#comp_ticket_details', :as => :comp_ticket_details
  match '/performances/:performance_id/tickets/comp_ticket_confirm' => 'tickets#comp_ticket_confirm', :as => :comp_ticket_confirm
  
  root :to => "index#index"
end
