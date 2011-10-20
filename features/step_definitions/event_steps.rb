When /^(?:|I )fill in the following event details:$/ do |table|
  event = event_from_table_row(table.hashes.first)
  setup_event(event)

  When %{I fill in "Name" with "#{event.name}"}
  When %{I fill in "Venue" with "#{event.venue}"}
  When %{I fill in "Producer" with "#{event.producer}"}
  When %{I fill in "City" with "#{event.city}"}
  When %{I select "#{us_states.invert[event.state]}" from "State"}
end

Given /^there is an [Ee]vent with (\d+) [Ss]hows$/ do |show_count|
  event = Factory(:event, :organization_id => @current_user.current_organization.id)

  setup_event(event)
  charts = setup_charts([Factory(:chart, :organization_id => @current_user.current_organization.id)])
  setup_performances(show_count.to_i.times.collect { Factory(:show, :event => current_event, :chart => charts.first, :organization_id => @current_user.current_organization.id) })
end

Given /^I view the (\d+)(?:st|nd|rd|th) [Ee]vent$/ do |pos|
  within(:xpath, "(//ul[@class='detailed-list']/li)[#{pos.to_i}]") do
    click_link "event-name"
  end
end

Given /^there is an event called "([^"]*)" with (\d+) shows with tickets$/ do |name, quantity|
  event = Factory(:event, :name => name)
  event.shows << quantity.to_i.times.collect { Factory(:show_with_tickets, :event => event) }
end
