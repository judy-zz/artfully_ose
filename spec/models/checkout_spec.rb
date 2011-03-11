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
    end

    it "should create a person record when finishing" do
      attributes = {
        :first_name => payment.customer.first_name,
        :last_name  => payment.customer.last_name,
        :email => payment.customer.email
      }

      AthenaPerson.should_receive(:create).with(attributes).and_return(Factory(:athena_person,attributes))

      subject.finish
    end

  end
end
