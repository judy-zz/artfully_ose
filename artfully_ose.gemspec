$:.push File.expand_path("../lib", __FILE__)

require "artfully_ose/version"

Gem::Specification.new do |s|
  s.name        = "artfully_ose"
  s.version     = ArtfullyOse::VERSION
  s.authors     = ["Artful.ly"]
  s.email       = ["support@artful.ly"]
  s.homepage    = "http://artfully_ose.github.com"
  s.summary     = "Artfully"
  s.description = "Artfully"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.6"
  s.add_dependency "devise", "=2.0.4"
  s.add_dependency "devise_invitable", "=1.0.2"
  
  s.add_dependency "activemerchant"
  s.add_dependency "braintree", "~> 2.16.0"
  
  s.add_dependency "delayed_job", "=3.0.2"
  s.add_dependency "delayed_job_active_record", "=0.3.2"
  s.add_dependency "activerecord-import", "0.2.9"
  s.add_dependency "acts-as-taggable-on", "~>2.1.0"
  s.add_dependency "haml"

  s.add_dependency "will_paginate", '~> 3.0'
  s.add_dependency "bootstrap-will_paginate"
  

  s.add_dependency "aws-sdk"
  s.add_dependency "paperclip", '>= 2.5.0'
  s.add_dependency "comma", '3.0.3'
  
  s.add_dependency "s3", '>= 0.3.11'
  s.add_dependency "validates_timeliness"
  
  s.add_development_dependency "sqlite3"
end
