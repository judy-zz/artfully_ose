# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'cancan/matchers'
require 'sunspot/rails/spec_helper'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.before(:each) { FakeWeb.clean_registry }
  config.before(:each) { FakeWeb.last_request = nil }
  config.before(:all) { FakeWeb.allow_net_connect = false }
  
  # Set some dummy S3 values.
  config.before(:all) do
    ENV["S3_BUCKET"] = "rspec"
    ENV["ACCESS_KEY_ID"] = "ABC1234567890DEFGHJK"
    ENV["SECRET_ACCESS_KEY"] = "abcdef12345+abcdef1234512345123451234512"
  end

end
