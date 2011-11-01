source 'http://rubygems.org'
gem 'rake', '0.8.7'
gem 'rails'

gem 'athena_resource'

gem 'delayed_job'

# Views and Rendering
gem 'haml'
gem 'sass'
gem 'dynamic_form'
gem 'will_paginate', '~> 3.0.beta'
gem 'high_voltage'
gem 'copycopter_client'
gem 'mail'
gem 'fastercsv'
gem 'jquery-rails', '>= 1.0.12'
gem 's3', '>= 0.3.8'
gem 'jammit'
gem 'jammit-s3', :path => "vendor/gems/jammit-s3-0.6.3"
gem 'comma',     :path => "vendor/gems/comma-0.4.0"

# Authentication and Roles
gem 'devise'
gem 'devise_invitable'
gem 'cancan'

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
  gem 'launchy'
  gem 'awesome_print', :require => 'ap'
  gem 'uuid'
  gem 'faker'
  gem 'rails-footnotes', '>= 3.7.5.rc4'
end

group :test do
  gem 'cucumber-rails'
  gem 'database_cleaner'
end
