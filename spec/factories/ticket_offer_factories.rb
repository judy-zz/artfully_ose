Factory.define :ticket_offer do |o|
  o.organization { Factory.create(:organization) }
end
