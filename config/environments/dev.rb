Artfully::Application.configure do
  config.log_level = :debug

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  config.action_mailer.smtp_settings = {
    :address        => "smtp.sendgrid.net",
    :port           => "25",
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => ENV['SENDGRID_DOMAIN']
  }

  config.action_mailer.default_url_options = { :host => 'artfully-dev.herokuapp.com' }
  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true
  
  #Fractured Atlas
  config.fractured_atlas = 'http://staging.api.fracturedatlas.org'

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.tickets_site       = 'http://184.73.209.105:8080/athena/'
  config.payments_component = 'http://184.73.209.105:8080/payments/'
  config.orders_component   = 'http://184.73.209.105:8080/athena/'
  config.stage_site         = 'http://184.73.209.105:8080/athena/'
  config.people_site        = 'http://184.73.209.105:8080/athena/'
  config.reports_site       = 'http://184.73.209.105:8080/athena/reports/'
  config.payments_element_name = '/payments'

  #config.athena_resource_user = 'demo'
  #config.athena_resource_password = 'LiberateTheArts!'
  #config.athena_resource_auth_type = 'digest'

  AthenaResource::USER_AGENT = "artful.ly"
  AthenaResource::USER = nil
  AthenaResource::PASSWORD = nil
  AthenaResource::AUTH_TYPE = nil
end

GravatarImageTag.configure do |config|
  #This has to be fully qualified URL.  Gravatar serves up the default form it's servers, not the local filesystem
  config.default_image = 'https://arfully-dev.s3.amazonaws.com/images/glyphish/gray/111-user2x.png'
end