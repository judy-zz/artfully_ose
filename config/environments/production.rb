Artfully::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = true

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.smtp_settings = {
    :address        => "smtp.sendgrid.net",
    :port           => "25",
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => ENV['SENDGRID_DOMAIN']
  }

  config.action_mailer.default_url_options = { :host => 'www.artfullyhq.com' }

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.tickets_site = 'http://athena-prduction.elasticbeanstalk.com/'
  config.orders_component = 'http://athena-prduction.elasticbeanstalk.com/'
  config.stage_site = 'http://athena-prduction.elasticbeanstalk.com/'
  config.people_site = 'http://athena-prduction.elasticbeanstalk.com/'
  config.reports_site = 'http://athena-prduction.elasticbeanstalk.com/reports/'
  
  config.payments_component = 'http://athena-payments-prod.elasticbeanstalk.com/'
  config.payments_element_name = ''

  config.athena_resource_user = ENV['ATHENA_RESOURCE_USER']
  config.athena_resource_password = ENV['ATHENA_RESOURCE_PASSWORD']
  config.athena_resource_auth_type = 'digest'
end
