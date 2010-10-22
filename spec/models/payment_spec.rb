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

  describe "with nested attributes" do
    it "should accept nested attributes for shipping address" do
      @shipping_address = Factory(:address)
      @payment = Factory(:payment, :shipping_address => @shipping_address.attributes)
      @payment.shipping_address.attributes.should == @shipping_address.attributes
    end

    it "should accept nested attributes for billing address" do
      @billing_address = Factory(:address)
      @payment = Factory(:payment, :billing_address => @billing_address.attributes)
      @payment.billing_address.attributes.should == @billing_address.attributes
    end

    it "should accept nested attributes for billing address" do
      @credit_card = Factory(:credit_card)
      @payment = Factory(:payment, :credit_card => @credit_card.attributes)
      @payment.credit_card.attributes.should == @credit_card.attributes
    end

  end
end
