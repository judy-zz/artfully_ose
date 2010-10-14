Factory.sequence :id do |n|
  "#{n}"
end

Factory.define :ticket, :default_strategy => :build do |t|
end

Factory.define :ticket_with_id, :class => Ticket, :default_strategy => :build do |t|
  t.id { Factory.next :id }
end
