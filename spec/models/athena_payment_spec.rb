require 'spec_helper'

describe AthenaPayment do
  subject { Factory(:payment) }

  before(:each) do
    @payment = Factory(:payment)
  end

  %w( amount customer credit_card billing_address ).each do |attribute|
    it { should respond_to attribute }
    it { should respond_to attribute + '=' }
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
    @billing_address = AthenaAddress.new
    @billing_address.should_not be_valid
    @payment.billing_address = @billing_address
    @payment.should_not be_valid
    @payment.errors.size.should == 1
  end

  it "should be invalid with an invalid credit card" do
    @credit_card = AthenaCreditCard.new
    @credit_card.should_not be_valid
    @payment.credit_card = @credit_card
    @payment.should_not be_valid
    @payment.errors.size.should == 1
  end

  it "should be invalid with an invalid customer" do
    @customer = AthenaCustomer.new
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

  describe "authorization" do

    it "should be neither accepted nor rejected until saved" do
      @payment.rejected?.should be_false
      @payment.approved?.should be_false
    end

    it "should request authorization from ATHENA" do
      FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success": true }')
      @body = @payment.encode  #Capture the body before we make the request.
      @payment.authorize!
      FakeWeb.last_request.method.should == "POST"
      FakeWeb.last_request.path.should == '/payments/transactions/authorize'
      FakeWeb.last_request.body.should == @body
    end

    describe "approval" do
      it "should respond to approved?" do
        @payment.should respond_to :approved?
      end

      it "should be approved when ATHENA returns success as true" do
        FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success": true }')
        @payment.authorize!
        @payment.approved?.should be_true
      end

      it "should return true when ATHENA returns success as true" do
        FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success": true }')
        @payment.authorize!.should be_true
      end
    end

    describe "rejection" do
      it "should respond to rejected?" do
        @payment.should respond_to :rejected?
      end

      it "should be rejected when ATHENA returns success as false" do
        FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success": false }')
        @payment.authorize!
        @payment.rejected?.should be_true
      end

      it "should return false when ATHENA returns success as false" do
        FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success": false }')
        @payment.authorize!.should be_false
      end
    end
  end
end
