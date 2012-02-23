require 'spec_helper'

describe Reseller::Order do
  disconnect_sunspot
  
  let(:reseller)          { Factory(:organization_with_reselling) }
  let(:joe_customer)      { Factory(:person) }
  let(:order)             { Factory(:reseller_order, :organization => reseller, :person => joe_customer) }
  
  let(:hamlet_producer)   { Factory(:organization) }
  let(:hamlet)            { Factory(:show, :organization => hamlet_producer) }
  let(:hamlet_tickets)    { 3.times.collect { Factory(:ticket, :show => hamlet) } }
  
  let(:cats_producer)     { Factory(:organization) }
  let(:cats)              { Factory(:show, :organization => cats_producer) }
  let(:cats_tickets)      { 2.times.collect { Factory(:ticket, :show => cats) } }
  
  describe "handling of ExternalOrders" do
    it "should create an ExternalOrder for each producer in the cart" do
      order << hamlet_tickets
      order << cats_tickets
      order.save
      #order.items.each { |item| item.reseller_order_id.should eq order.id }
      order.external_orders.length.should eq 2
    end
  end
  
  it "should report the total amount of the order" do
  end
  
  it "should report the total reseller fees on the order" do
  end
end