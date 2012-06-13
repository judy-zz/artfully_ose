require 'spec_helper'

describe Reseller::Order do
  disconnect_sunspot
  
  let(:reseller_profile)  { Factory(:reseller_profile) }
  let(:reseller)          { reseller_profile.organization }
  let(:joe_customer)      { Factory(:person) }
  let(:order)             { Factory(:reseller_order, :organization => reseller, :person => joe_customer) }
  
  let(:hamlet_producer)   { Factory(:organization) }
  let(:hamlet)            { Factory(:show, :organization => hamlet_producer) }
  let(:hamlet_tickets)    { 3.times.collect { Factory(:ticket, :show => hamlet, :organization => hamlet_producer) } }
  
  let(:cats_producer)     { Factory(:organization) }
  let(:cats)              { Factory(:show, :organization => cats_producer) }
  let(:cats_tickets)      { 2.times.collect { Factory(:ticket, :show => cats, :organization => cats_producer) } }
  
  before(:each) do
    order << hamlet_tickets
    order << cats_tickets
    order.save
  end
  
  describe "handling of ExternalOrders" do
    it "should create an ExternalOrder for each producer in the cart" do
      order.external_orders.length.should eq 2
      order.external_orders.each do |o|
        o.transaction_id.should   eq order.transaction_id
        o.service_fee.should      eq order.service_fee
        o.payment_method.should   eq order.payment_method
      end
    end
    
    #
    # TODO: find_or_create people records for each org on the order
    #
    it "should create or link to people records for each individual org on the order" do
      order.external_orders.each do |o|
        o.person.should_not eq order.person
      end      
    end
    
    it "should attach the items to this order via reseller_order" do
      order.items.each do |item| 
        item.reseller_order_id.should eq order.id
        item.order.id.should_not eq order.id
      end
    end
    
    it "should attach the items to the proper external orders" do
      order.external_orders.each do |external_order|
        external_order.items.each do |item|
          item.order.id.should eq external_order.id
        end
        
        if external_order.organization == cats_producer
          external_order.items.length.should eq 2
        elsif external_order.organization == hamlet_producer
          external_order.items.length.should eq 3
        end
      end
    end
  end
  
  it "should set the reseller net to whatever the reseller profile's fee is" do
    order.items.each { |item| item.reseller_net.should eq reseller_profile.fee }
  end
  
  it "should report the total amount of the order" do
    order.total.should eq (hamlet_tickets.inject(0) {|sum, ticket| sum + ticket.price.to_i } + cats_tickets.inject(0) {|sum, ticket| sum + ticket.price.to_i })
  end
  
  it "should report the total reseller fees on the order" do
    order.reseller_fee.should eq ((hamlet_tickets.length + cats_tickets.length) * reseller_profile.fee)
  end
end