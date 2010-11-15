Factory.sequence :id do |n|
  "#{n}"
end

Factory.define :ticket, :class => Athena::Ticket, :default_strategy => :build do |t|
  t.event { Faker::Lorem.words(2).join(" ") }
  t.venue { Faker::Lorem.words(2).join(" ") + " Theatre"}
  t.performance { DateTime.now }
  t.sold false
  t.price "50.00"
end

Factory.define :ticket_with_id, :class => Athena::Ticket, :default_strategy => :build do |t|
  t.id { Factory.next :id }
end
