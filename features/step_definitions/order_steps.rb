Given /^I enter my payment details$/ do
  payment = Factory(:payment)

  with_scope('#customer') do
    fill_in("First Name",:with => payment.customer.first_name)
    fill_in("Last Name",:with => payment.customer.last_name)
    fill_in("Phone",:with => payment.customer.phone)
    fill_in("Email",:with => payment.customer.email)
  end

  with_scope('#credit_card') do
    fill_in("Cardholder Name",:with => payment.credit_card.cardholder_name)
    fill_in("Number",:with => payment.credit_card.card_number)
    fill_in("CVV",:with => payment.credit_card.cvv)
  end

  with_scope('#billing_address') do
    fill_in("First Name",:with => payment.billing_address.first_name)
    fill_in("Last Name",:with => payment.billing_address.last_name)
    fill_in("Street Address",:with => payment.billing_address.street_address1)
    fill_in("City",:with => payment.billing_address.city)
    fill_in("State",:with => payment.billing_address.state)
    fill_in("Postal Code",:with => payment.billing_address.postal_code)
  end

  click_button("Purchase")
end

Given /^I have added (\d+) tickets to my order$/ do |a_few|
  producer = Factory(:user)
  event = Factory(:athena_event_with_id, :producer_pid => producer.athena_id )
  tickets = a_few.to_i.times.collect { Factory(:ticket_with_id, :event_id => event.id) }

  FakeWeb.register_uri(:any, %r|http://localhost/tix/meta/locks/.*\.json|, :body => Factory(:lock, :tickets => tickets.collect(&:id)).encode)
  body = tickets.collect { |ticket| "tickets[]=#{ticket.id}" }.join("&")
  page.driver.post "/order", body
end

Given /^I have added (\d+) donations to my order$/ do |a_few|
  recipient = Factory(:user)
  donations = a_few.to_i.times.collect { Factory.build(:donation, :producer_pid => recipient.athena_id) }
  donations.each do |donation|
    page.driver.post "/order", "donation[amount]=#{donation.amount}&donation[producer_id]=#{recipient.id}"
  end
end

Given /^I start the checkout process$/ do
  visit new_checkout_path
end

When /^I visit the order page$/ do
  pending # express the regexp above with the code you wish you had
end
