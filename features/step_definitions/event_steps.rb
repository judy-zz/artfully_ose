When /^(?:|I )fill in the following event details:$/ do |table|
  event = event_from_table_row(table.hashes.first)

  setup_event(event)
  setup_charts([Factory(:athena_chart, :producer_pid => @user.athena_id)])
  setup_performances([])

  When %{I fill in "Name" with "#{event.name}"}
  When %{I fill in "Venue" with "#{event.venue}"}
  When %{I fill in "Producer" with "#{event.producer}"}
  When %{I fill in "City" with "#{event.city}"}
  When %{I select "#{event.valid_locales.key(event.state)}" from "State"}
end

Given /^there is an [Ee]vent with (\d+) [Pp]erformances for "([^"]*)"$/ do |performance_count, email|
  user = User.find_by_email(email)
  event = Factory(:athena_event_with_id, :producer_pid => user.athena_id)

  setup_event(event)
  charts = setup_charts([Factory(:athena_chart, :producer_pid => user.athena_id)])
  setup_performances(3.times.collect { Factory(:athena_performance_with_id, :event => current_event, :chart => charts.first, :producer_pid => user.athena_id) })

  visit events_path
  Given %{I follow "#{event.name}"}
end

Given /^I view the (\d+)(?:st|nd|rd|th) [Ee]vent$/ do |pos|
  within(:xpath, "(//tbody/tr)[#{pos.to_i}]") do
    click_link "event-name"
  end
end