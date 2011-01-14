Factory.define :lock, :class => AthenaLock, :default_strategy => :build do |t|
  t.id { UUID.new.generate }
  t.lock_expires { DateTime.now + 1.hour }
  t.after_build do |lock|
    FakeWeb.register_uri(:get, "http://localhost/tix/meta/locks/#{lock.id}.json", :status => 200, :body => lock.encode)
  end
end

Factory.define :expired_lock, :parent => :lock, :default_strategy => :build do |t|
  t.lock_expires { DateTime.now - 1.hour }
end

Factory.sequence :ticket_id do |n|
  "#{n}"
end

Factory.define :ticket, :class => AthenaTicket, :default_strategy => :build do |t|
  t.event { Faker::Lorem.words(2).join(" ") }
  t.venue { Faker::Lorem.words(2).join(" ") + " Theatre"}
  t.performance { DateTime.now }
  t.sold false
  t.price "50.00"
end

Factory.define :ticket_with_id, :parent => :ticket, :default_strategy => :build do |t|
  t.id { Factory.next :ticket_id }
  t.after_build do |ticket|
    FakeWeb.register_uri(:get, "http://localhost/tix/tickets/#{ticket.id}.json", :status => 200, :body => ticket.encode)
  end
end