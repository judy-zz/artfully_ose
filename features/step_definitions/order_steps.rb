Given /^I enter my payment details$/ do
  person = Factory(:athena_person_with_id)
  FakeWeb.register_uri(:get, %r|http://localhost/people/people.*|, :body => "[#{person.encode}]")
  FakeWeb.register_uri(:post, "http://localhost/people/people.json", :body => person.encode)
  payment = Factory(:payment)

  with_scope('"#customer"') do
    fill_in("First Name",:with => payment.customer.first_name)
    fill_in("Last Name",:with => payment.customer.last_name)
    fill_in("Phone",:with => payment.customer.phone)
    fill_in("Email",:with => payment.customer.email)
  end

  with_scope('"#credit_card"') do
    fill_in("Cardholder Name",:with => payment.credit_card.cardholder_name)
    fill_in("Number",:with => payment.credit_card.card_number)
    fill_in("CVV",:with => payment.credit_card.cvv)
  end

  with_scope('"#billing_address"') do
    fill_in("Street Address",:with => payment.billing_address.street_address1)
    fill_in("City",:with => payment.billing_address.city)
    fill_in("State",:with => payment.billing_address.state)
    fill_in("Postal Code",:with => payment.billing_address.postal_code)
  end

  click_button("Purchase")
end

Given /^I have added (\d+) tickets to my order$/ do |a_few|
  producer = Factory(:user)
  producer.organizations << Factory(:organization_with_donations)
  event = Factory(:athena_event_with_id, :organization_id => producer.current_organization.id )
  tickets = a_few.to_i.times.collect { Factory(:ticket_with_id, :event_id => event.id) }

  FakeWeb.register_uri(:any, %r|http://localhost/tix/meta/locks/.*\.json|, :body => Factory(:lock, :tickets => tickets.collect(&:id)).encode)
  body = tickets.collect { |ticket| "tickets[]=#{ticket.id}" }.join("&")
  page.driver.post "/store/order", body
end

Given /^I have added (\d+) donations to my order$/ do |a_few|
  organization = Factory(:organization)
  donations = a_few.to_i.times.collect { Factory.build(:donation, :organization => organization) }
  donations.each do |donation|
    page.driver.post "/store/order", "donation[amount]=#{donation.amount}&donation[organization_id]=#{organization.id}"
  end
end

Given /^I start the checkout process$/ do
  visit new_store_checkout_path
end

Then /^an email confirmation for the order should have been sent$/ do
  ActionMailer::Base.deliveries.should_not be_empty
end
