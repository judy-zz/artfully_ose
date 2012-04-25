Given /^the customer goes to the storefront for my event$/ do
  visit store_event_path(current_event)
end

Then /^the customer should see the published shows$/ do
  current_event.upcoming_public_shows.each do |show|
    page.should have_xpath("(//ul[@id='shows']/li[@id='show_#{show.id}'])")
  end
  
  current_event.shows.reject{|s| s.published?}.each do |show|
    page.should have_no_xpath("(//ul[@id='shows']/li[@id='show_#{show.id}'])")
  end
end

Then /^all the checkout panel links$/ do
  page.should have_xpath("(//ul[@id='nav']/li[contains(.,'Cart')])")
  page.should have_xpath("(//ul[@id='nav']/li[contains(.,'Contact Info')])")
  page.should have_xpath("(//ul[@id='nav']/li[contains(.,'Payment Details')])")
  page.should have_xpath("(//ul[@id='nav']/li[contains(.,'Billing Address')])")
  page.should have_xpath("(//ul[@id='nav']/li[contains(.,'Purchase')])")
end

And /^not the special instructions link$/ do
  page.should have_no_xpath("(//ul[@id='nav']/li[contains(.,'Special Instructions')])")
end

And /^the special instructions link$/ do
  page.should have_xpath("(//ul[@id='nav']/li[contains(.,'Special Instructions')])")
end