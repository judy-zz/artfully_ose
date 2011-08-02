# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Artfully::Application.initialize!
ActiveResource::Base.include_root_in_json = false
ActiveResource::Base.logger = ActiveRecord::Base.logger

# Turn off field_with_errors wrapping
# See: http://d.strelau.net/post/163547069/remove-div-fieldwitherrors-from-rails-forms
ActionView::Base.field_error_proc = proc {|html, instance| html }