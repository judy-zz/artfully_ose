Given /^I check the (\d+)(?:st|nd|rd|th) ticket for a refund$/ do |pos|
  within(:xpath, "(//div[@id='refunds']/form/ul/li)[#{pos.to_i}]") do
    check("items[]")
  end
end

