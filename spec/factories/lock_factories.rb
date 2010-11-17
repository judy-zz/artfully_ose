Factory.define :lock, :class => AthenaLock, :default_strategy => :build do |t|
  t.id { UUID.new.generate }
end

Factory.define :unexpired_lock, :parent => :lock, :default_strategy => :build do |t|
  t.lockExpires { 1.week.from_now }
end

Factory.define :expired_lock, :parent => :lock, :default_strategy => :build do |t|
  t.lockExpires { 1.week.ago }
end
