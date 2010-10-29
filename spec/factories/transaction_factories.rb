Factory.define :transaction, :default_strategy => :build do |t|
  t.id { UUID.new.generate }
end
