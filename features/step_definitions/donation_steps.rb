Then /^I should see (\d+) donations$/ do |quantity|
  page.should have_xpath("//tr[@class='donation']", :count => quantity)
end