require 'spec_helper'

describe Reseller::Cart do
  describe "ticket fee" do
    let(:reseller_profile)    { Factory(:reseller_profile) }
    let(:reseller)            { reseller_profile.organization }
    let(:tickets)             { 2.times.collect { Factory(:ticket) } }
    let(:free_tickets)        { 2.times.collect { Factory(:free_ticket) } }
    let(:cart)                { Reseller::Cart.new(reseller) }
    
    before(:each) do
      cart.reseller = reseller
    end
    
    it "should be zero if nothing is in the cart" do
      cart.fee_in_cents.should eq 0
    end
    
    it "should be zero for free tickets" do
      cart << free_tickets
      cart.fee_in_cents.should eq 0
    end
    
    it "should be equal to the number of tickets in the cart plus 1 * each ticket plus reseller_fee * tickets" do
      cart << tickets
      cart.fee_in_cents.should eq 1200
    end
    
    it "should not assess a fee on an item where the reseller is also the producer of the item" do
      #Case where someone is selling their own tickets
    end
  end 
end