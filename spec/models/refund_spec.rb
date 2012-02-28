require 'spec_helper'

describe Refund do
  disconnect_sunspot
  let(:items) { 3.times.collect { Factory(:item)}}
  let(:order) { Factory(:order, :service_fee => 600, :items => items) }
  subject { Refund.new(order, items) }
  
  gateway = ActiveMerchant::Billing::BraintreeGateway.new(
      :merchant_id => Artfully::Application.config.BRAINTREE_MERCHANT_ID,
      :public_key  => Artfully::Application.config.BRAINTREE_PUBLIC_KEY,
      :private_key => Artfully::Application.config.BRAINTREE_PRIVATE_KEY
    )    
  
  successful_response = ActiveMerchant::Billing::Response.new(true, 'nice job!', {}, {:authorization => '3e4r5q'} )
  fail_response = ActiveMerchant::Billing::Response.new(false, 'you failed!')
  
  before(:each) do
    items.each { |i| i.order = order }
    ActiveMerchant::Billing::BraintreeGateway.stub(:new).and_return(gateway)
  end

  describe "#submit" do
    before(:each) do
      gateway.should_receive(:refund).with(3600, order.transaction_id).and_return(successful_response)
      
      subject.items.each { |i| i.stub(:return!) }
      subject.items.each { |i| i.stub(:refund!) }
    end

    it "should attempt to refund the payment made for the order" do
      subject.submit
      subject.should be_successful
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
      
      subject.refund_order.transaction_id.should eq '3e4r5q'
      
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
      subject.refund_amount.should eq total + order.service_fee
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
      gateway.should_receive(:refund).with(3600, order.transaction_id).and_return(successful_response)
      subject.submit
      subject.should be_successful
    end
  
    it "should return false if the refund was not successful" do
      gateway.should_receive(:refund).with(3600, order.transaction_id).and_return(fail_response)
      subject.submit
      subject.should_not be_successful
    end
  end
  
  describe "a partial refund" do
    before(:each) do
      subject.items.each { |i| i.stub(:return!) }
      subject.items.each { |i| i.stub(:refund!) }
      subject.stub(:create_refund_order)
    end
    
    it "should return the amount for only those orders being refunded" do
      refundable_items = items[0..1]
      partial_refund = Refund.new(order, refundable_items)
      partial_refund.refund_amount.should eq 2400
    end
    
    it "should issue a refund for the amount being refunded" do
      refundable_items = items[0..1]
      gateway.should_receive(:refund).with(2400, order.transaction_id).and_return(successful_response)
      partial_refund = Refund.new(order, refundable_items)
      partial_refund.submit
      partial_refund.items.length.should eq 2
    end
  end

end
