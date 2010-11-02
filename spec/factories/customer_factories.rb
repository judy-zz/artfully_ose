Factory.define :customer, :default_strategy => :build do |a|
  a.first_name  "First"
  a.last_name "Last"
  a.phone "123 456 7890"
  a.email "customer@test.com"
end
