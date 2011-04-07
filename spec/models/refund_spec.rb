require 'spec_helper'

describe Refund do
  let(:order) { Factory(:athena_order_with_id) }
  let(:items) { 3.times.collect { Factory(:athena_item)}}
  subject { Refund.new(order, items) }

  before(:each) do
    items.each { |item| item.stub(:refund!).and_return(true) }
  end

  describe "#submit" do
    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/payments/transactions/refund", :body => "{ success: true }")
      subject.stub(:create_refund_order)
    end

    it "should attempt to refund the payment made for the order" do
      subject.submit
      FakeWeb.last_request.method.should eq "POST"
      FakeWeb.last_request.path.should eq "/payments/transactions/refund"
    end

    it "should include the total price of all items being refunded" do
      total = subject.refund_amount / 100.0
      subject.submit
      FakeWeb.last_request.body.should match Regexp.new(/\"amount\":#{total}/)
    end
  end

  describe "refund_amount" do
    it "should return the total for the items in the refund in cents" do
      total = items.collect(&:price).reduce(:+)
      subject.refund_amount.should eq total
    end
  end

  describe "successful?" do
    before(:each) do
      subject.stub(:create_refund_order)
    end

    it "should return false if it has not been submitted" do
      subject.should_not be_successful
    end

    it "should return true if the refund was successful" do
      FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/refund', :body => '{ "success": true }')
      subject.submit
      subject.should be_successful
    end

    it "should return false if the refund was not successful" do
      FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/refund', :body => '{ "success": false }')
      subject.submit
      subject.should_not be_successful
    end
  end

end
