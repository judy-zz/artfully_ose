When /^I fill in my event details of "([^"]*)" and "([^"]*)"$/ do |event_name, venue_name|
  step %{I fill in "I'm organizing" with "#{event_name}"}
  step %{I fill in "that happens at" with "#{venue_name}"}  
end

Given /^there is an [Ee]vent with (\d+) [Ss]hows$/ do |show_count|
  event = Factory(:event, :organization_id => @current_user.current_organization.id)
  event.charts << Factory(:chart_with_sections)

  setup_event(event)
  setup_shows(show_count.to_i.times.collect { Factory(:show, :event => current_event, :organization_id => @current_user.current_organization.id) })
end

Given /^there is an Event with special instructions with (\d+) Shows$/ do |show_count|
  event = Factory(:event, :organization_id => @current_user.current_organization.id, :show_special_instructions => true)
  event.charts << Factory(:chart_with_sections)

  setup_event(event)
  setup_shows(show_count.to_i.times.collect { Factory(:show, :event => current_event, :organization_id => @current_user.current_organization.id) })
end

Given /^I view the (\d+)(?:st|nd|rd|th) [Ee]vent$/ do |pos|
  within(:xpath, "(//ul[@id='event-list']/li)[#{pos.to_i}]") do
    click_link "event-name"
  end
end

Given /^there is an event called "([^"]*)" with (\d+) shows with tickets$/ do |name, quantity|
  @current_user ||= Factory(:user_in_organization)
  event = Factory(:event, :name => name, :organization => @current_user.current_organization)
  event.shows << quantity.to_i.times.collect { Factory(:show_with_tickets, :event => event, :organization => event.organization) }
  current_shows(event.shows)
end
