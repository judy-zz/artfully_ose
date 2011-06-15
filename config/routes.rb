Artfully::Application.routes.draw do

  scope :module => :api do
    constraints :subdomain => "api" do
      resources :events, :only => :show
      resources :tickets, :only => :index
      resources :organizations, :only => [] do
        get :authorization
      end
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
    resources :kits
  end

  devise_for :users

  resources :organizations do
    resources :memberships
    member do
      post :connect
    end
  end

  resources :kits, :except => :index do
    get :alternatives, :on => :collection
  end

  resources :credit_cards, :except => :show

  resources :people, :except => :destroy do
    resources :actions
  end

  resources :events do
    resources :performances do
      member do
        get :door_list
        post :duplicate
        put :put_on_sale
        put :take_off_sale
      end
    end
  end

  resources :performances, :only => [] do
    resources :tickets, :only => [] do
      collection do
        delete :delete
        put :on_sale
        put :off_sale
        put :bulk_edit
        put :change_prices
        get :set_new_price
      end
    end
  end

  resources :comps, :only => [ :new, :create ]

  resources :charts do
    resources :sections
  end

  resources :help, :only => [ :index ]

  resources :orders
  resources :refunds, :only => [ :new, :create ]
  resources :exchanges, :only => [ :new, :create ]
  resources :returns, :only => :create

  match '/events/:event_id/charts/assign/' => 'charts#assign', :as => :assign_chart
  match '/performances/:id/createtickets/' => 'performances#createtickets', :as => :create_tickets_for_performance
  match '/people/:id/star/:type/:action_id' => 'people#star', :as => :star, :via => "post"

  match '/dashboard' => 'index#dashboard', :as => :dashboard
  root :to => 'index#login_success', :constraints => lambda {|r| r.env["warden"].authenticate? }

  root :to => 'index#index'

end
