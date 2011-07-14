Factory.define :lock, :class => AthenaLock, :default_strategy => :build do |t|
  t.id { UUID.new.generate }
  t.lock_expires { DateTime.now + 1.hour }
  t.after_build do |lock|
    FakeWeb.register_uri(:get, "http://localhost/athena/locks/#{lock.id}.json", :status => 200, :body => lock.encode)
    FakeWeb.register_uri(:post, "http://localhost/athena/locks.json", :status => 200, :body => lock.encode)
    FakeWeb.register_uri(:delete, "http://localhost/athena/locks/#{lock.id}.json", :status => 204, :body => "")
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
  t.performance { DateTime.now + 1.month }
  t.price "5000"
end

Factory.define :sold_ticket, :parent => :ticket do |t|
  t.state "sold"
  t.sold_price "5000"
  t.sold_at Time.now
end

Factory.define :ticket_with_id, :parent => :ticket, :default_strategy => :build do |t|
  t.id { Factory.next :ticket_id }
  t.event_id { Factory(:athena_event_with_id).id }
  t.performance_id { Factory(:athena_performance_with_id).id }
  t.price "3000"
  t.after_build do |ticket|
    FakeWeb.register_uri(:get, "http://localhost/athena/tickets/#{ticket.id}.json", :status => 200, :body => ticket.encode)
    FakeWeb.register_uri(:put, "http://localhost/athena/tickets/#{ticket.id}.json", :status => 200, :body => ticket.encode)
  end
end

Factory.define :sold_ticket_with_id, :parent => :sold_ticket, :default_strategy => :build do |t|
  t.id { Factory.next :ticket_id }
  t.event_id { Factory(:athena_event_with_id).id }
  t.performance_id { Factory(:athena_performance_with_id).id }
  t.after_build do |ticket|
    FakeWeb.register_uri(:get, "http://localhost/athena/tickets/#{ticket.id}.json", :status => 200, :body => ticket.encode)
    FakeWeb.register_uri(:put, "http://localhost/athena/tickets/#{ticket.id}.json", :status => 200, :body => ticket.encode)
  end
end