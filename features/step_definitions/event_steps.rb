When /^(?:|I )fill in the following event details:$/ do |table|
  event = event_from_table_row(table.hashes.first)
  setup_event(event)
  setup_charts([Factory(:athena_chart, :organization_id => event.organization_id)])
  setup_performances([])

  When %{I fill in "Name" with "#{event.name}"}
  When %{I fill in "Venue" with "#{event.venue}"}
  When %{I fill in "Producer" with "#{event.producer}"}
  When %{I fill in "City" with "#{event.city}"}
  When %{I select "#{event.valid_locales.invert[event.state]}" from "State"}
end

Given /^there is an [Ee]vent with (\d+) [Pp]erformances$/ do |performance_count|
  event = Factory(:athena_event_with_id, :organization_id => @current_user.current_organization.id)

  setup_event(event)
  charts = setup_charts([Factory(:athena_chart, :organization_id => @current_user.current_organization.id)])
  setup_performances(performance_count.to_i.times.collect { Factory(:athena_performance_with_id, :event => current_event, :chart => charts.first, :organization_id => @current_user.current_organization.id) })

  visit events_path
  Given %{I follow "#{event.name}"}
end

Given /^I view the (\d+)(?:st|nd|rd|th) [Ee]vent$/ do |pos|
  within(:xpath, "(//tbody/tr)[#{pos.to_i}]") do
    click_link "event-name"
  end
end