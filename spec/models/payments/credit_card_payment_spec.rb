require 'spec_helper'
require 'active_merchant_test_helper'

describe CreditCardPayment do
  include ActiveMerchantTestHelper
  
  describe "through the factory" do
    it "should be registered as a payment method" do
      [:credit_card, :credit_card_manual, :credit_card_swipe].each do |cc_type|
        credit_card_payment = Payment.create(cc_type, {:amount => 3000})
        credit_card_payment.class.name.should eq "CreditCardPayment"
        credit_card_payment.amount.should eq 3000
      end
    end
  end
  
  describe "initialization" do
    it "should amount in initialize" do
      params = { :amount => 3000 }
      @payment = CreditCardPayment.new(:amount => 3000)
      @payment.amount.should eq 3000
    end
    
    it "should build from params" do
      params = {}
      params[:customer], params[:customer][:address], params[:credit_card] = {}, {}, {}
      params[:amount] = 3000
      
      params[:customer][:first_name] = "Gary"
      params[:customer][:last_name] = "Moore"
      params[:customer][:email] = "gary.moore@fracturedatlas.org"
      params[:customer][:phone] = "5712417836"
      params[:customer][:address][:address1] = "100 WEST 33 RD STREET"
      params[:customer][:address][:city] = "BROOKLYN"
      params[:customer][:address][:state] = "NY"
      params[:customer][:address][:zip] = "11238"
      params[:credit_card][:name] = "CARD NAME"
      params[:credit_card][:number] = "4111111111111111"
      params[:credit_card][:verification_value] = "333"
      params[:credit_card][:month] = "01"
      params[:credit_card][:year] = "2014"
      params[:user_agreement] = 1
      
      @payment = CreditCardPayment.new(params)
      @payment.amount.should eq params[:amount]
      @payment.customer.first_name.should             eq params[:customer][:first_name]
      @payment.customer.last_name.should              eq params[:customer][:last_name]
      @payment.customer.email.should                  eq params[:customer][:email]
      @payment.customer.phones.first.number.should    eq params[:customer][:phone]

      params[:customer][:address].each do |key, value| 
        @payment.customer.address.send("#{key}").should eq value
      end
      
      params[:credit_card].each do |key, value| 
        @payment.credit_card.send("#{key}").should eq value
      end
      
    end
  end
  
  describe "contacting the gateway" do
    before(:each) do
      subject.credit_card = credit_card
      subject.amount = 1000
    end
    
    it "should purchase" do
      gateway.should_receive(:purchase).with(1000, credit_card, {}).and_return(successful_response)
      subject.purchase.should eq successful_response
    end
    
    it "should pass options through when purchasing" do
      options = {:a => "b"}
      gateway.should_receive(:purchase).with(1000, credit_card, options).and_return(successful_response)
      subject.purchase(options).should eq successful_response
    end
    
    it "should authorize" do
      gateway.should_receive(:authorize).with(1000, credit_card, {}).and_return(successful_response)
      subject.authorize.should eq successful_response
    end
    
    it "should settle" do
      gateway.should_receive(:capture).with(1000, successful_response.authorization, {}).and_return(successful_response)
      subject.capture(successful_response)
    end
  end
  
  describe ".amount" do
    it "should be valid with an amount set" do
      subject.amount = 1000
      subject.should be_valid
    end

    it "should be invalid without an amount" do
      subject = Factory.build(:credit_card_payment, :amount => nil)
      subject.should_not be_valid
    end

    it "should be invalid with an amount less than zero" do
      subject.amount = -1000
      subject.should_not be_valid
    end

    it "should convert cents to dollars when assigning the amount" do
      subject.amount = 1000
      subject.amount.should eq 1000
    end
  end
  
  describe "reduce amount" do
    it "should reduce the amount" do
      subject.amount = 1000
      subject.reduce_amount_by 501
      subject.amount.should eq 499
    end
  end
end
