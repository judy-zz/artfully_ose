When /^(?:|I )fill in the following event details:$/ do |table|
  event = event_from_table_row(table.hashes.first)
  setup_event(event)

  When %{I fill in "Name" with "#{event.name}"}
  When %{I fill in "event[venue_attributes][name]" with "#{event.venue.name}"}
  When %{I fill in "Producer" with "#{event.producer}"}
  When %{I fill in "City*" with "#{event.venue.city}"}
  When %{I select "#{us_states.invert[event.venue.state]}" from "State"}
end

Given /^there is an [Ee]vent with (\d+) [Ss]hows$/ do |show_count|
  event = Factory(:event, :organization_id => @current_user.current_organization.id)
  event.charts << Factory(:chart_with_sections)

  setup_event(event)
  setup_shows(show_count.to_i.times.collect { Factory(:show, :event => current_event, :organization_id => @current_user.current_organization.id) })
end

Given /^I view the (\d+)(?:st|nd|rd|th) [Ee]vent$/ do |pos|
  within(:xpath, "(//ul[@class='detailed-list']/li)[#{pos.to_i}]") do
    click_link "event-name"
  end
end

Given /^there is an event called "([^"]*)" with (\d+) shows with tickets$/ do |name, quantity|
  @current_user ||= Factory(:user_in_organization)
  event = Factory(:event, :name => name, :organization => @current_user.current_organization)
  event.shows << quantity.to_i.times.collect { Factory(:show_with_tickets, :event => event, :organization => event.organization) }
  current_shows(event.shows)
end
