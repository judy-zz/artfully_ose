Factory.define :reseller_event do |f|
  f.name "Some Event"
  f.producer "Some Producer"
  f.venue { Factory(:venue) }
end
