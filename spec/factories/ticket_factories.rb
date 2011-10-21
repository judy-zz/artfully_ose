Factory.define :ticket do |t|
  t.venue { Faker::Lorem.words(2).join(" ") + " Theatre"}
  t.price 5000
  t.association :show
  t.association :organization
end

Factory.define :free_ticket, :parent => :ticket do |t|
  t.venue { Faker::Lorem.words(2).join(" ") + " Theatre"}
  t.price 0
  t.association :show
  t.association :organization
end

Factory.define :sold_ticket, :parent => :ticket do |t|
  t.on_sale!
  t.state :sold
  t.after_create do |ticket|
    ticket.sell_to(Factory(:person))
  end
end