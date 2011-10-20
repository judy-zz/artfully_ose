Factory.sequence :datetime do |n|
  (DateTime.now + n.days)
end

Factory.define(:show) do |s|
  s.datetime { Factory.next :datetime }
  s.association :organization
  s.association :event
  s.association :chart, :factory => :assigned_chart
end

Factory.define(:show_with_tickets, :parent => :show) do |s|
  s.after_create do |show|
    show.create_tickets
  end
end

Factory.define(:expired_show, :parent => :show, :default_strategy => :build) do |s|
  s.datetime { DateTime.now - 1.day}
end
