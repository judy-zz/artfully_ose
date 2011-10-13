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

Factory.define :ticket do |t|
  t.venue { Faker::Lorem.words(2).join(" ") + " Theatre"}
  t.price "5000"
  t.association :show
end

Factory.define :sold_ticket, :parent => :ticket do |t|
  t.state "sold"
  t.after_create do |ticket|
    ticket.sell_to(Factory(:person))
  end
end