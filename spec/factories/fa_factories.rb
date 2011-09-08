Factory.define :fa_user, :class => FA::User, :default_strategy => :build do |f|
  f.email "user@fracturedatlas.org"
  f.username "user"
  f.password "password"
end

Factory.define :fa_user_with_member_id, :class => FA::User, :default_strategy => :build do |f|
  f.email "user@fracturedatlas.org"
  f.username "user"
  f.password "password"
  f.member_id 44539
end