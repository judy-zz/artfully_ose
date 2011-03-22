require 'spec_helper'

describe Checkout do
  let(:payment) { Factory(:payment) }
  let(:order) { Factory(:order) }

  subject { Checkout.new(order, payment) }

  it "should store the payment" do
    subject.payment.should be payment
  end

  it "should store the order" do
    subject.order.should be order
  end

  it "should set the amount for the payment from the order" do
    subject.payment.amount.should eq order.total
  end

  it "should not be valid without a payment" do
    subject.payment = nil
    subject.should_not be_valid
  end

  it "should not be valid without an order" do
    subject.order = nil
    subject.should_not be_valid
  end

  it "should not be valid if the payment is invalid" do
    subject.payment.stub(:valid?).and_return(false)
    subject.should_not be_valid
  end

  describe "finish" do
    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/payments/transactions/authorize", :body => '{ "success":true }')
      FakeWeb.register_uri(:post, "http://localhost/payments/transactions/settle", :body => '{ "success":true }')
      subject.order.stub(:pay_with)
    end

    it "should create a person record when finishing with a new customer" do
      subject.order.stub(:organizations_from_tickets).and_return(Array.wrap(Factory(:organization)))
      
      email = payment.customer.email
      organization = subject.order.organizations_from_tickets.first
      
      AthenaPerson.should_receive(:find_by_email_and_organization).with(email, organization).and_return(nil)

      attributes = {
        :email => email,
        :organization_id => organization.id,
        :first_name => payment.customer.first_name,
        :last_name  => payment.customer.last_name
      }

      AthenaPerson.should_receive(:create).with(attributes).and_return(Factory(:athena_person,attributes))

      subject.finish
    end

    it "should not create a person record when the person already exists" do
      subject.order.stub(:organizations_from_tickets).and_return(Array.wrap(Factory(:organization)))
      
      email = payment.customer.email
      organization = subject.order.organizations_from_tickets.first
      
      attributes = {
        :email => email,
        :organization_id => organization.id,
        :first_name => payment.customer.first_name,
        :last_name  => payment.customer.last_name
      }
      
      AthenaPerson.should_receive(:find_by_email_and_organization).with(email, organization).and_return(Factory(:athena_person,attributes))
      AthenaPerson.should_not_receive(:create)

      subject.finish
    end

  end
end
