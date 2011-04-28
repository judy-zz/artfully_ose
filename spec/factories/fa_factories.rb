Factory.define :fa_user, :class => FA::User, :default_strategy => :build do |f|
  f.email "user@fracturedatlas.org"
  f.username "user"
  f.password "password"
end