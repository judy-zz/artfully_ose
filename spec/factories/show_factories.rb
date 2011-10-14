Factory.sequence :datetime do |n|
  (DateTime.now + n.days)
end

Factory.define(:show) do |p|
  p.datetime { Factory.next :datetime }
  p.association :organization
  # TODO
  p.chart_id 1
end

Factory.define(:expired_show, :parent => :show, :default_strategy => :build) do |s|
  s.datetime { DateTime.now - 1.day}
end
