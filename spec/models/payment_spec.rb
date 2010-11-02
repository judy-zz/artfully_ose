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

  it "should be invalid with an invalid customer" do
    @customer = Customer.new
    @customer.should_not be_valid
    @payment.customer = @customer
    @payment.should_not be_valid
    @payment.errors.size.should == 1
  end

  describe "with nested attributes" do
    it "should accept nested attributes for billing address" do
      @billing_address = Factory(:address)
      @payment = Factory(:payment, :billing_address => @billing_address)
      @payment.billing_address.attributes.should == @billing_address.attributes
    end

    it "should accept nested attributes for credit card" do
      @credit_card = Factory(:credit_card)
      @payment = Factory(:payment, :credit_card => @credit_card)
      @payment.credit_card.attributes.should == @credit_card.attributes
    end

    it "should accept nested attributes for customer" do
      @customer = Factory(:customer)
      @payment = Factory(:payment, :customer => @customer)
      @payment.customer.attributes.should == @customer.attributes
    end
  end

  it "should respond to approved?" do
    @payment.respond_to?(:approved?).should be_true
  end

  it "should be approved when ATHENA returns success as true" do
    FakeWeb.register_uri(:post, 'http://localhost/payments/.json', :status => 200, :body => '{ "success":true}')
    @payment.save
    @payment.approved?.should be_true
  end

  it "should respond to rejected?" do
    @payment.respond_to?(:rejected?).should be_true
  end

  it "should be rejected when ATHENA returns success as false" do
    FakeWeb.register_uri(:post, 'http://localhost/payments/.json', :status => 200, :body => '{ "success":false}')
    @payment.save
    @payment.rejected?.should be_true
  end

  it "should be neither accepted nor rejected until saved" do
    @payment.rejected?.should be_false
    @payment.approved?.should be_false
  end
end
