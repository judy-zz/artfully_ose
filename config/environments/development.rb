Artfully::Application.configure do
  config.log_level = :debug

  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  
  #Fractured Atlas
  config.fractured_atlas = 'http://staging.api.fracturedatlas.org'

  config.tickets_site     = 'http://localhost:8080/athena/'
  config.orders_component = 'http://localhost:8080/athena/'
  config.stage_site       = 'http://localhost:8080/athena/'
  config.people_site      = 'http://localhost:8080/athena/'
  config.reports_site     = 'http://localhost:8080/athena/reports/'
  config.payments_component = 'http://localhost:8080/payments/'
  config.payments_element_name = '/payments'

  AthenaResource::USER_AGENT = "artful.ly"
  AthenaResource::USER = nil
  AthenaResource::PASSWORD = nil
  AthenaResource::AUTH_TYPE = nil
  
end

