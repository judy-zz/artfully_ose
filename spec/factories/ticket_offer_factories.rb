Factory.define :ticket_offer do |f|
  f.organization { Factory.create(:organization) }
  f.reseller_profile { |o| Factory.create(:reseller_profile, :organization_id => o.organization_id) }
  f.show { Factory.create(:show) }
  f.section { Factory.create(:section) }
end
