$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "artfully_ose/version"

# Describe your gem and declare its dependencies:
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
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
