When /^I check the (\d+)(?:st|nd|rd|th) ticket for a return$/ do |pos|
  within(:xpath, "(//div[@id='returns']/form/ul/li)[#{pos.to_i}]") do
    check("items[]")
  end
end