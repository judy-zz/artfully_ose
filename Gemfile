source 'http://rubygems.org'
gem 'rake', '0.8.7'
gem 'rails'

# Views and Rendering
gem 'haml'
gem 'sass'
gem 'will_paginate', '~> 3.0.beta'
gem 'high_voltage'
gem 'jquery-rails', '>= 0.2.6'

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
gem 'whenever'
gem 'rack-jsonp-middleware', :require => 'rack/jsonp'
gem 'exceptional'
gem 'transitions',
    :require => ['transitions','active_record/transitions','active_resource/transitions'],
    :path => "#{File.expand_path(__FILE__)}/../vendor/gems/transitions-0.0.9"

group :test do
  gem 'sqlite3-ruby', :require => 'sqlite3'
end

group :deployment do
  gem 'capistrano'
  gem 'capistrano-ext'
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
