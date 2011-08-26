Artfully::Application.routes.draw do

  namespace :api do
    resources :events, :only => :show
    resources :tickets, :only => :index
    resources :organizations, :only => [] do
      get :authorization
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
    resources :settlements, :only => [ :index, :new, :create ]
    resources :organizations do

      resources :events, :only => :show do
        resources :shows, :only => :show
      end

      resources :kits do
        put :activate, :on => :member
      end

      resources :memberships
      resource  :bank_account, :except => :show
    end
    resources :kits
  end

  devise_for :users

  resources :organizations do
    put :tax_info, :on => :member
    resources :memberships
    member do
      post :connect
    end
  end

  resources :kits, :except => :index do
    get :alternatives, :on => :collection
  end

  resources :reports, :only => :index
  resources :settlements, :only => [ :index, :show ]
  resources :statements, :only => [ :index, :show ]

  resources :credit_cards, :except => :show

  resources :people, :except => :destroy do
    resources :actions
    resources :phones, :only => [:create, :destroy]
  end
  resources :segments

  resources :events do
    get :widget, :on => :member
    resources :shows do
      member do
        get :door_list
        post :duplicate
      end
      collection do
        post :built
        post :on_sale
        post :published
        post :unpublished
      end
    end
  end

  resources :shows, :only => [] do
    resources :tickets, :only => [ :new, :create ] do
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

  resources :charts do
    resources :sections
  end

  resources :help, :only => [ :index ]

  resources :orders do
    collection do
      get :sales
    end
  end

  resources :contributions

  resources :refunds, :only => [ :new, :create ]
  resources :exchanges, :only => [ :new, :create ]
  resources :returns, :only => :create
  resources :comps, :only => [ :new, :create ]
  resources :pages

  match '/events/:event_id/charts/' => 'events#assign', :as => :assign_chart, :via => "post"
  match '/people/:id/star/:type/:action_id' => 'people#star', :as => :star, :via => "post"
  match '/people/:id/tag/' => 'people#tag', :as => :new_tag, :via => "post"
  match '/people/:id/tag/:tag' => 'people#untag', :as => :untag, :via => "delete"
  match '/statements/events/:event_id' => 'statements#index', :as => :event_statements, :via => "get"
  match '/statements/shows/:performance_id' => 'statements#show', :as => :show_statement, :via => "get"

  match '/dashboard' => 'index#dashboard', :as => :dashboard
  root :to => 'index#login_success', :constraints => lambda {|r| r.env["warden"].authenticate? }

  root :to => 'index#index'

end
