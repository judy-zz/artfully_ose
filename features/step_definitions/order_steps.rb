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

Given /^I have started an order$/ do
  ids = []
  (1..2).each do |id|
    ticket = Factory(:ticket_with_id, :id => id)
    ids << id
  end
  FakeWeb.register_uri(:any, %r|http://localhost/tix/meta/locks/.*\.json|, :status => [ 200 ], :body => Factory(:unexpired_lock, :tickets => ids).encode)
  post "/orders", "tickets[]=1&tickets[]=2"
end

Given /^I start the checkout process$/ do
  visit new_checkout_path
end