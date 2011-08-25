source 'http://rubygems.org'
gem 'rake', '0.8.7'
gem 'rails'

gem 'athena_resource'

# Views and Rendering
gem 'haml'
gem 'sass'
gem 'dynamic_form'
gem 'will_paginate', '~> 3.0.beta'
gem 'high_voltage'
gem 'copycopter_client'
gem 'mail'
gem 'comma', :git => "git://github.com/crafterm/comma.git"
gem 'fastercsv'
gem 'jquery-rails', '>= 1.0.12'
gem 'jammit'
gem 'jammit-s3', :git => "git://github.com/railsjedi/jammit-s3.git"

# Authentication and Roles
gem 'devise'
gem 'devise_invitable'
gem 'cancan'
gem 'role_model'

# Validations
gem 'validates_timeliness'

gem 'thin'
gem 'mysql2', '< 0.3'
gem 'escape_utils'
gem 'httparty'
gem 'rack-jsonp-middleware', :require => 'rack/jsonp'
gem 'exceptional'
gem 'newrelic_rpm'
gem 'transitions',
    :require => ['transitions','active_record/transitions','active_resource/transitions'],
    :path => "#{File.expand_path(__FILE__)}/../vendor/gems/transitions-0.0.9"

group :test do
  gem 'sqlite3-ruby', :require => 'sqlite3'
end

group :deployment do
  gem 'heroku'
end

group :test, :development do
  gem "rspec-rails", ">= 2.1"
  gem 'shoulda'
  gem 'fakeweb'
  gem 'factory_girl_rails'
  gem 'nokogiri'
  gem 'capybara'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'awesome_print', :require => 'ap'
  gem 'uuid'
  gem 'faker'
  gem 'jasmine'
end
