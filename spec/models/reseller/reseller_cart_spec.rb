require 'spec_helper'

describe Reseller::Cart do
  describe "ticket fee" do
    let(:reseller_profile)    { Factory(:reseller_profile) }
    let(:reseller)            { reseller_profile.organization }
    let(:tickets)             { 2.times.collect { Factory(:ticket) } }
    let(:free_tickets)        { 2.times.collect { Factory(:free_ticket) } }
    let(:cart)                { Reseller::Cart.new( {:reseller => reseller} )  }
    
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
    
    #
    # Case where someone is re-selling their own tickets.  
    # Fee should roll back to regular fees
    #
    it "should not assess a fee on an item where the reseller is also the producer of the item" do
      pending
    end
  end 

  describe "adding tickets to a cart on an offer with no tickets available" do
    let(:cart) { Factory :reseller_cart }
    let(:ticket) { Factory :ticket }
    let(:ticket_offer) { Factory :ticket_offer, reseller_profile: cart.reseller.reseller_profile, show: ticket.show, section: ticket.section, count: 0 }

    it "should not hold any more tickets" do
      cart.should_not be_can_hold ticket
    end
  end

  describe "adding tickets to a cart on an offer with tickets available" do
    let(:cart) { Factory :reseller_cart }
    let(:ticket) { Factory :ticket }
    let(:ticket_offer) { Factory :ticket_offer, organization: ticket.organization, reseller_profile: cart.reseller.reseller_profile, show: ticket.show, section: ticket.section, count: 1 }

    it "should hold another ticket" do
      ticket_offer.should_not be_nil # Force the offer to be built.
      cart.should be_can_hold ticket
    end
  end
end
