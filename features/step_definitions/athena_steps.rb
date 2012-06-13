Given /^I can save Credit Cards to ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/payments/cards.json", :status => 200)
end

Given /^I can authorize Credit Cards in ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/payments/transactions/authorize", :body => "{ \"success\":true, \"transaction_id\":\"j59qrb\" }")
end

Given /^I can settle Credit Cards in ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/payments/transactions/settle", :body => "{ \"success\" : true }")
end

Given /^I can refund tickets through Braintree$/ do
  gateway = ActiveMerchant::Billing::BraintreeGateway.new(
      :merchant_id => Artfully::Application.config.BRAINTREE_MERCHANT_ID,
      :public_key  => Artfully::Application.config.BRAINTREE_PUBLIC_KEY,
      :private_key => Artfully::Application.config.BRAINTREE_PRIVATE_KEY
    )    
  
  successful_response = ActiveMerchant::Billing::Response.new(true, 'nice job!', {}, {:authorization => '3e4r5q'} )
  gateway.stub(:refund).and_return(successful_response)
  ActiveMerchant::Billing::BraintreeGateway.stub(:new).and_return(gateway)
end

Given /^I can save Customers to ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/payments/customers.json", :body => Factory.build(:customer_with_id).encode)
end