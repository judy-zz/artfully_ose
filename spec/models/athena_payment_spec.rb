require 'spec_helper'

describe AthenaPayment do
  subject { Factory(:payment) }

  %w( amount customer credit_card billing_address ).each do |attribute|
    it { should respond_to attribute }
    it { should respond_to attribute + '=' }
  end

  describe ".amount" do
    it "should be valid with an amount set" do
      subject.amount = 10.00
      subject.should be_valid
    end

    it "should be invalid without an amount" do
      subject = Factory(:payment, :amount => nil)
      subject.should_not be_valid
    end

    it "should be invalid with an amount less than zero" do
      subject.amount = -10.00
      subject.should_not be_valid
    end
  end

  describe "with nested attributes" do
    it "should be invalid with an invalid billing address" do
      subject.billing_address.stub(:valid?).and_return(false)
      subject.should_not be_valid
      subject.errors.size.should eq 1
    end

    it "should accept nested attributes for billing address" do
      billing_address = Factory(:address)
      subject.billing_address = billing_address
      subject.billing_address.attributes.should == billing_address.attributes
    end

    it "should be invalid with an invalid credit card" do
      subject.credit_card.stub(:valid?).and_return(false)
      subject.should_not be_valid
      subject.errors.size.should eq 1
    end

    it "should accept nested attributes for credit card" do
      credit_card = Factory(:credit_card)
      subject.credit_card = credit_card
      subject.credit_card.attributes.should == credit_card.attributes
    end

    it "should accept nested attributes for customer" do
      customer = Factory(:customer)
      subject.customer = customer
      subject.customer.attributes.should == customer.attributes
    end

    it "should be invalid with an invalid customer" do
      subject.customer.stub(:valid?).and_return(false)
      subject.should_not be_valid
      subject.errors.size.should eq 1
    end
  end

  describe "authorization" do
    it { should_not be_approved }
    it { should_not be_rejected }

    it "should request authorization from ATHENA" do
      FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success": true }')
      body = subject.encode  #Capture the body before we make the request.
      subject.authorize!
      FakeWeb.last_request.method.should == "POST"
      FakeWeb.last_request.path.should == '/payments/transactions/authorize'
      FakeWeb.last_request.body.should == body
    end

    describe "approval" do
      it "should respond to approved?" do
        subject.should respond_to :approved?
      end

      it "should be approved when ATHENA returns success as true" do
        FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success": true }')
        subject.authorize!
        subject.approved?.should be_true
      end

      it "should return true when ATHENA returns success as true" do
        FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success": true }')
        subject.authorize!.should be_true
      end
    end

    describe "rejection" do
      it "should respond to rejected?" do
        subject.should respond_to :rejected?
      end

      it "should be rejected when ATHENA returns success as false" do
        FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success": false }')
        subject.authorize!
        subject.rejected?.should be_true
      end

      it "should return false when ATHENA returns success as false" do
        FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success": false }')
        subject.authorize!.should be_false
      end
    end
  end
end
