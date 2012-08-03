Factory.define :ticket_offer do |f|

  f.organization do |to|
    Factory :organization
  end

  f.reseller_profile do |to|
    reseller = Factory :organization_with_reselling
    reseller.reseller_profile
  end

  f.show do |to|
    event = Factory :event, organization: to.organization
    Factory.create :show, event: event
  end

  f.section do |to|
    chart = Factory :chart, event: to.show.event, organization: to.organization
    Factory.create :section, chart: chart
  end

end
