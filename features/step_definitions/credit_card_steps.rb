Given /^I navigate to my credit cards page$/ do
  Given %{I am on the root page}
  And %{I follow "Dashboard"}
  And %{I follow "Credit Cards"}
end

Given /^there are (\d+) saved credit cards for "([^"]*)"$/ do |quantity, email|
  cards = []
  quantity.to_i.times do
    card = Factory(:credit_card)
    cards << card
    FakeWeb.register_uri(:any, "http://localhost/payments/cards/#{card.id}.json", :status => 200, :body => card.encode)
  end
  @customer = Factory(:customer_with_id)
  @customer.credit_cards = cards
  current_user = User.find_by_email(email)
  current_user.customer = @customer
  current_user.save
  FakeWeb.register_uri(:get, "http://localhost/payments/customers/#{@customer.id}.json", :status => 200, :body => @customer.encode)
end

When /^I delete the (\d+)(?:st|nd|rd|th) credit card$/ do |pos|
  @customer.credit_cards.delete_at(pos.to_i-1)
  FakeWeb.register_uri(:get, "http://localhost/payments/customers/#{@customer.id}.json", :status => 200, :body => @customer.encode)
  within("#credit_cards li:nth-child(#{pos.to_i})") do
    When %{I follow "Delete"}
  end
end

Then /^I should see (\d+) credit cards in the credit card list$/ do |quantity|
  page.has_xpath? "//li[@class='credit_card']", :count => 2
end