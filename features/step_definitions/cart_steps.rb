Given /^I enter my payment details$/ do
  payment = Factory.build(:payment)

  with_scope('"#customer"') do
    fill_in("athena_payment_athena_customer_first_name",:with => payment.customer.first_name)
    fill_in("athena_payment_athena_customer_last_name",:with => payment.customer.last_name)
    fill_in("athena_payment_athena_customer_phone",:with => payment.customer.phone)
    fill_in("athena_payment_athena_customer_email",:with => payment.customer.email)
  end

  with_scope('"#credit_card"') do
    fill_in("athena_payment_athena_credit_card_cardholder_name",:with => payment.credit_card.cardholder_name)
    fill_in("athena_payment_athena_credit_card_card_number",:with => payment.credit_card.card_number)
    fill_in("athena_payment_athena_credit_card_cvv",:with => payment.credit_card.cvv)
  end

  with_scope('"#billing_address"') do
    fill_in("athena_payment_billing_address_street_address1",:with => payment.billing_address.street_address1)
    fill_in("athena_payment_billing_address_city",:with => payment.billing_address.city)
    select(payment.billing_address.state, :from => "athena_payment_billing_address_state")
    fill_in("athena_payment_billing_address_postal_code",:with => payment.billing_address.postal_code)
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
