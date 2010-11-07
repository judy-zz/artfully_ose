Factory.define :transaction, :class => Athena::Transaction, :default_strategy => :build do |t|
  t.id { UUID.new.generate }
end

Factory.define :unexpired_transaction, :parent => :transaction, :default_strategy => :build do |t|
  t.lockExpires { 1.week.from_now }
end

Factory.define :expired_transaction, :parent => :transaction, :default_strategy => :build do |t|
  t.lockExpires { 1.week.ago }
end
