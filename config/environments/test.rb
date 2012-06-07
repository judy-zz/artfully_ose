Artfully::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  #Fractured Atlas
  config.fractured_atlas = 'http://staging.api.fracturedatlas.org/'

  config.tickets_site = 'http://localhost/athena/'
  config.payments_component = 'http://localhost/payments/'
  config.orders_component = 'http://localhost/athena/'
  config.stage_site = 'http://localhost/athena/'
  config.people_site = 'http://localhost/athena/'
  config.reports_site = 'http://localhost/athena/reports/'

  config.payments_element_name = '/payments'
  
  ActiveMerchant::Billing::Base.mode = :test

  AthenaResource::USER_AGENT = "artful.ly"
  AthenaResource::USER = nil
  AthenaResource::PASSWORD = nil
  AthenaResource::AUTH_TYPE = nil

  # Set some dummy S3 values.
  ENV["S3_BUCKET"] = "test"
  ENV["ACCESS_KEY_ID"] = "ABC1234567890DEFGHJK"
  ENV["SECRET_ACCESS_KEY"] = "abcdef12345+abcdef1234512345123451234512"
  
  #Dummy mailchimp values
  ENV["MC_API_KEY"]="d-us1"
  ENV["MC_LIST_ID"]="d"

end
