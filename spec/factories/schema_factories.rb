Factory.sequence :id do |n|
  n
end

Factory.sequence :name do |n|
  "Field#{n}"
end

Factory.sequence :valueType do
  types = %w( STRING DATETIME BOOLEAN INTEGER )
  types[rand(types.size)]
end

Factory.define :field, :default_strategy => :build do |t|
  t.id { Factory.next :id }
  t.name { Factory.next :name }
  t.strict "false"
  t.valueType { Factory.next :valueType } 
end
