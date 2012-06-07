source 'http://rubygems.org'
gem 'rake', '0.8.7'
gem 'rails', '3.1.2'
gem 'rack-ssl-enforcer'
gem 'rack-canonical-host'

#rails 3.1
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'activemerchant', :require => 'active_merchant'
gem 'athena_resource'
gem 'activerecord-import', '0.2.9'
gem 'delayed_job', '=3.0.2'
gem 'delayed_job_active_record', '=0.3.2'
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
gem 'copycopter_client', '2.0.1'
gem 'mail'
gem 'jquery-rails', '>= 1.0.19'
gem 's3', '>= 0.3.11'
gem 'set_watch_for', :path => "vendor/gems/set_watch_for-0.0.1"
gem 'swiper', :path => "vendor/gems/swiper-0.0.1"
gem 'jammit'
gem 'jammit-s3', :path => "vendor/gems/jammit-s3-0.6.3"
gem 'aws-sdk'
gem 'paperclip', '>= 2.5.0'
gem 'comma', '3.0.3'
gem 'nokogiri' # for pulling in blog posts on index#updates

# Authentication and Roles
gem 'devise'
gem 'devise_invitable'
gem 'cancan'

# Validations
gem 'validates_timeliness'

gem 'uuid'
gem 'thin'
gem 'mysql2', "0.3.11"
gem 'escape_utils'
gem 'httparty'
gem 'rack-jsonp-middleware', :require => 'rack/jsonp'
gem 'exceptional'
gem 'newrelic_rpm'
gem 'transitions', :require => ['transitions', 'active_record/transitions']
gem 'sunspot_rails'
gem 'gravatar_image_tag'

group :test do
  gem 'sqlite3', '1.3.6'
  gem 'timecop'
  gem "rspec-rails", ">= 2.1"
  gem 'shoulda'
  gem 'fakeweb'
  gem 'faker'
  gem 'factory_girl_rails', "= 1.0.1"
  
  gem 'autotest-rails'
  gem 'autotest-fsevent'
  gem 'autotest-growl'
  gem 'cucumber-rails'
  gem 'database_cleaner'
end

group :deployment do
  gem 'heroku', "> 2.20"
end

group :test, :development do
  gem 'nokogiri'
  gem 'capybara'
  gem 'launchy'
  gem 'awesome_print', :require => 'ap'
  gem 'rails-footnotes', '>= 3.7.5.rc4'
  gem 'wirble'
  gem 'sunspot_solr'
end
