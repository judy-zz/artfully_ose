# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Artfully::Application.initialize!
ActiveResource::Base.include_root_in_json = false
ActiveResource::Base.logger = ActiveRecord::Base.logger