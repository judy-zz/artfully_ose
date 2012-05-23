source 'http://rubygems.org'
gem 'rake', '0.8.7'
gem 'rails'
gem 'rack-ssl-enforcer'
gem 'rack-canonical-host'

gem 'activemerchant', :require => 'active_merchant'

gem 'athena_resource'
gem 'activerecord-import'

gem 'delayed_job', '=3.0.2'
gem 'delayed_job_active_record'
gem 'acts-as-taggable-on', '~>2.1.0'
gem 'restful_metrics'

#Mailchimp
gem 'gibbon'

# Views and Rendering
gem 'haml'
gem 'sass'
gem 'dynamic_form'
gem 'will_paginate', '~> 3.0', :require => [ "will_paginate", "will_paginate/array" ]
gem 'bootstrap-will_paginate'
gem 'copycopter_client'
gem 'mail'
gem 'fastercsv'
gem 'jquery-rails', '>= 1.0.19'
gem 's3', '>= 0.3.11'
gem 'set_watch_for', :path => "vendor/gems/set_watch_for-0.0.1"
gem 'swiper', :path => "vendor/gems/swiper-0.0.1"
gem 'jammit'
gem 'jammit-s3', :path => "vendor/gems/jammit-s3-0.6.3"
gem 'aws-sdk'
gem 'paperclip', '>= 2.5.0'
gem 'comma',     :path => "vendor/gems/comma-0.4.0"
gem 'nokogiri' # for pulling in blog posts on index#updates

# Authentication and Roles
gem 'devise'
gem 'devise_invitable'
gem 'cancan'

# Validations
gem 'validates_timeliness'

gem 'uuid'
gem 'thin'
gem 'mysql2', '< 0.3'
gem 'escape_utils'
gem 'httparty'
gem 'rack-jsonp-middleware', :require => 'rack/jsonp'
gem 'exceptional'
gem 'newrelic_rpm'
gem 'transitions', :require => ['transitions', 'active_record/transitions']
gem 'sunspot_rails'
gem 'gravatar_image_tag'

group :test do
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'timecop'
end

group :deployment do
  gem 'heroku'
end

group :test, :development do
  gem "rspec-rails", ">= 2.1"
  gem 'shoulda'
  gem 'fakeweb'
  gem 'factory_girl_rails', "= 1.0.1"
  gem 'nokogiri'
  gem 'capybara'
  gem 'launchy'
  gem 'awesome_print', :require => 'ap'
  gem 'faker'
  gem 'rails-footnotes', '>= 3.7.5.rc4'
  gem 'sunspot_solr'
end

group :test do
  gem 'autotest-rails'
  gem 'autotest-fsevent'
  gem 'autotest-growl'
  gem 'cucumber-rails'
  gem 'database_cleaner'
end
