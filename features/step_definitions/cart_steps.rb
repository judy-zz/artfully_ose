Given /^I enter my payment details$/ do
  payment = Factory.build(:payment)

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
    select(payment.billing_address.state, :from => "State")
    fill_in("Postal Code",:with => payment.billing_address.postal_code)
  end

  click_button("Purchase")
end

Given /^I have added (\d+) tickets to my order for "([^"]*)"$/ do |quantity, name|
  event = Event.find_by_name(name)
  tickets = event.shows.first.tickets.take(quantity.to_i)
  body = tickets.collect { |ticket| "tickets[]=#{ticket.id}" }.join("&")
  page.driver.post "/store/order", body
end

Given /^I have added (\d+) donations to my order$/ do |quantity|
  organization = Factory(:organization)
  donations = quantity.to_i.times.collect { Factory.build(:donation, :organization => organization) }
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
