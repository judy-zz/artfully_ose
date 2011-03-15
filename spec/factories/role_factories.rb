Factory.define :role do |r|
  r.name "SomeRole"
end

Factory.define :admin_role, :parent => :role do |r|
  r.name "admin"
end
