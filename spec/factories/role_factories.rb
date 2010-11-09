Factory.define :role do |r|
  r.name "SomeRole"
end

Factory.define :admin_role, :parent => :role do |r|
  r.name "admin"
end

Factory.define :patron_role, :parent => :role do |r|
  r.name "patron"
end

Factory.define :producer_role, :parent => :role do |r|
  r.name "producer"
end
