require 'active_support'
require 'active_resource'

module AthenaResource
  include ActiveResource

  extend ActiveSupport::Autoload
  autoload :Base
  autoload :Headers
end


# Provide a method at the class level that would allow someone to declare this is an athena resource
