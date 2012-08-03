require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  require 'factory_girl'
  require 'factory_girl_rails'
  FactoryGirl.definition_file_paths.push('#{File.dirname(__FILE__)}/factories') 

  ENV["RAILS_ENV"] = 'test'
  require File.expand_path("../dummy/config/environment.rb",  __FILE__)
  require 'rspec/rails'
  require 'cancan/matchers'
  require 'sunspot/rails/spec_helper'
  FactoryGirl.find_definitions

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

  RSpec.configure do |config|
    config.mock_with :rspec

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
  
  #ActiveSupport::Dependencies.clear
end

Spork.each_run do
  FactoryGirl.reload
  Dir["#{File.dirname(__FILE__)}/../app/models/*.rb"].each { |model| load model }
  Dir["#{File.dirname(__FILE__)}/../lib/artfully_ose/app/models/*.rb"].each { |model| load model }
end