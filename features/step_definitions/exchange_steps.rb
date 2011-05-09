When /^I check the (\d+)(?:st|nd|rd|th) ticket for an exchange$/ do |pos|
  within(:xpath, "(//div[@id='exchanges']/form/ul/li)[#{pos.to_i}]") do
    check("items[]")
  end
end

Given /^I have found (\d+) items to exchange$/ do |num|
  Given %{there is an order with an ID of 1 and #{num} tickets}
  Given %{I look up order 1}
  num.to_i.times do |n|
    Given %{I check the #{n+1}th ticket for an exchange}
  end
  Given %{I press "Exchange"}
end

When /^I select the (\d+)(?:st|nd|rd|th) event$/ do |pos|
  within(:xpath, "(//ul[@id='event-drilldown']/li)[#{pos.to_i}]") do
    click_link("event-name")
  end
end

When /^I select the (\d+)(?:st|nd|rd|th) performance$/ do |pos|
  within(:xpath, "(//ul[@id='performance-drilldown']/li)[#{pos.to_i}]") do
    click_link("performance-datetime")
  end
end

Then /^there should not be any tickets available to exchange$/ do
  page.should have_no_xpath("(//div[@id='exchanges']/form/ul/li)")
end

When /^I check (\d+) tickets$/ do |num|
  num.to_i.times do |pos|
    within(:xpath, "(//ul[@id='ticket-drilldown']/li)[#{pos + 1}]") do
      check("tickets[]")
    end
  end
end
