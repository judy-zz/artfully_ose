require 'spec_helper'

describe Payment do

  before(:each) do
    @payment = Factory(:payment)
  end

  it "should include amount" do
    @payment.respond_to?(:amount).should be_true
  end


  it "should be valid with an amount set" do
    @payment.amount = 10.00
    @payment.should be_valid
  end

  it "should be invalid without an amount" do
    @payment = Factory(:payment, :amount => nil)
    @payment.should_not be_valid
  end

  it "should be invalid with an amount less than zero" do
    @payment.amount = -10.00
    @payment.should_not be_valid
  end

  it "should be invalid with an invalid shipping address" do
    @shipping_address = Address.new
    @shipping_address.should_not be_valid
    @payment.shipping_address = @shipping_address
    @payment.should_not be_valid
    @payment.errors.size.should == 1
  end

  it "should be invalid with an invalid billing address" do
    @billing_address = Address.new
    @billing_address.should_not be_valid
    @payment.billing_address = @billing_address
    @payment.should_not be_valid
    @payment.errors.size.should == 1
  end

  it "should be invalid with an invalid credit card" do
    @credit_card = CreditCard.new
    @credit_card.should_not be_valid
    @payment.credit_card = @credit_card
    @payment.should_not be_valid
    @payment.errors.size.should == 1
  end
end
