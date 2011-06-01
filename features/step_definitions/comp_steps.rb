Given /^I check the (\d+)(?:st|nd|rd|th) ticket for a comp$/ do |pos|
  within(:xpath, "(//div[@id='comps']/form/ul/li)[#{pos.to_i}]") do
    check("selected_tickets[]")
  end
end
