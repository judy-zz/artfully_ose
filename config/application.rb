require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'rack/jsonp'

require 'yaml'
YAML::ENGINE.yamler = 'syck'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Artfully
  class Application < Rails::Application  
    # Raise exception on mass assignment protection for Active Record models
    config.active_record.mass_assignment_sanitizer = :strict

    # Log the query plan for queries taking more than this (works
    # with SQLite, MySQL, and PostgreSQL)
    config.active_record.auto_explain_threshold_in_seconds = 0.5  
    
    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    
    #For asset precompilation on Heroku
    config.assets.initialize_on_precompile = false

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"] # include all subdirectories
    config.autoload_paths += Dir["#{Rails.root.to_s}/app/models/**/"]


    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
    config.plugins = [ :athenaresource, :devise_suspendable, :d2s3 ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'UTC' #"Eastern Time (US & Canada)" #'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation, :card_number, :cvv]

    # Load JSONP middleware.
    config.middleware.use Rack::JSONP
  
    config.BRAINTREE_MERCHANT_ID = ENV['BRAINTREE_MERCHANT_ID'] || 'bzy5dt9tm5x3jvys'
    config.BRAINTREE_PUBLIC_KEY = ENV['BRAINTREE_PUBLIC_KEY'] || 'n8xrkpmvkdmgxqgc'
    config.BRAINTREE_PRIVATE_KEY = ENV['BRAINTREE_PRIVATE_KEY'] || '6gnq5wzg79rtbq4v'
    
  end
end

GravatarImageTag.configure do |config|
  config.default_image = 'fake.jpg'
  config.rating        = nil   # Set this if you change the rating of the images that will be returned ['G', 'PG', 'R', 'X']. Gravatar's default is G
  config.size          = nil   # Set this to globally set the size of the gravatar image returned (1..512). Gravatar's default is 80
  config.secure        = true 
end
