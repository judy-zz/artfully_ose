Then /^I should see (\d+) donations$/ do |quantity|
  page.has_xpath? "//li[@class='donation']", :count => quantity
end