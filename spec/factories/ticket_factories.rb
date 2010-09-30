Factory.sequence :id do |n|
  "#{n}"
end

Factory.sequence :field do |n|
  "field#{n}".to_sym
end

Factory.sequence :value do |n|
  "value#{n}"
end

Factory.define :ticket, :default_strategy => :build do |t|
  t.id Factory.next :id
  t.name 'ticket'
end

Factory.define :ticket_with_fields, :default_strategy => :build do |t|
  t.id Factory.next :id
  t.name 'ticket'
  5.times do 
    t.send Factory.next(:field), Factory.next(:value)
  end
end
