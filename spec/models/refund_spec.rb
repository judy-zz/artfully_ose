require 'spec_helper'

describe Refund do
  disconnect_sunspot
  let(:order) { Factory(:order) }
  let(:items) { 3.times.collect { Factory(:item, :order => order)}}
  subject { Refund.new(order, items) }

  describe "#submit" do
    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/payments/transactions/refund", :body => "{ success: true }")
      subject.items.each { |i| i.stub(:return!) }
      subject.items.each { |i| i.stub(:refund!) }
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
    
    it "should create a refund_order with refunded items" do
      subject.submit
      subject.refund_order.should_not be_nil
      subject.refund_order.items.should_not be_empty
      subject.refund_order.items.size.should eq 3
      subject.refund_order.items.each do |item|
        item.order.should eq subject.refund_order
        item.price.should eq (items.first.price * -1)
        item.realized_price.should eq (items.first.realized_price * -1)
        item.net.should eq (items.first.net * -1)
      end
      
      #and don't touch the original items
      items.each do |original_item|
        original_item.order.should eq order     
      end
      subject.refund_order.parent.should eq order   
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
      subject.items.each { |i| i.stub(:return!) }
      subject.items.each { |i| i.stub(:refund!) }
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

  describe "a partial refund" do
    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/payments/transactions/refund", :body => "{ success: true }")
      subject.items.each { |i| i.stub(:return!) }
      subject.items.each { |i| i.stub(:refund!) }
      subject.stub(:create_refund_order)
    end
    
    it "should return the amount for only those orders being refunded" do
      refundable_items = items[0..1]
      partial_refund = Refund.new(order, refundable_items)
      partial_refund.refund_amount.should eq refundable_items.collect(&:price).reduce(:+)
    end
    
    it "should issue a refund for the amount being refunded" do
      refundable_items = items[0..1]
      partial_refund = Refund.new(order, refundable_items)
      partial_refund.submit
      (FakeWeb.last_request.body.include? "20.0").should be_true
      partial_refund.items.length.should eq 2
    end
  end

end
