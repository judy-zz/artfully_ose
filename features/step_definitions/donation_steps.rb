Then /^I should see (\d+) donations$/ do |quantity|
  page.should have_xpath("//li[@class='donation']", :count => quantity)
end