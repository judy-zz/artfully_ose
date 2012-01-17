require 'spec_helper'

describe FinanceSummary do
  disconnect_sunspot
  let(:orders)        { 6.times.collect { Factory(:order) } }
  let(:organization)  { Factory(:organization) }
  let(:settlements)   { 3.times.collect { Factory(:settlement) } }
  
  describe "Happy Path" do
    before(:each) do
      orders[2].per_item_processing_charge = lambda { |item| item.realized_price * 0.035 }
      (0..2).each do |i|
        orders[i] << 3.times.collect { Factory(:sold_ticket) }
        orders[i].service_fee = 3 * 200
      end
    
      orders[2] << Factory(:donation)
    
      orders[3] << 2.times.collect { Factory (:free_ticket) }
      orders[4] << 4.times.collect { Factory (:comped_ticket) } 
      orders[4].to_comp!
    
      #FAFS order
      orders[5] << Factory(:sponsored_donation)
      orders[5].transaction_id = nil
      orders[5].fa_id = "34gfoin"
    
      @finance_summary = FinanceSummary.new(orders, settlements)
    end
  
    describe "Settlements" do
      it "should total up the settlements" do
        @finance_summary.settlements.net_settlements.should eq 300000
      end
    
      it "should report the number of settlements" do
        @finance_summary.settlements.num_settlements.should eq 3
      end
    end
  
    describe "Tickets" do
      it "should calculate gross Ticket data" do
        @finance_summary.all_tickets.gross_sales.should eq 45000
      end  
  
      it "should report the total number of tickets sold" do
        @finance_summary.all_tickets.sold.length.should eq 9
      end
  
      it "should report the free tickets" do
        @finance_summary.all_tickets.free.length.should eq 2
      end
  
      it "should count comped tickets" do
        @finance_summary.all_tickets.comped.length.should eq 4
      end
    end
  
    describe "Donations" do
      it "should report goss donations receipts and ignore FAFS" do
        @finance_summary.donations.gross_donations.should eq 1000
      end
    
      it "should count the number of artful.ly donations" do
        @finance_summary.donations.num_donations.should eq 1
      end
    end
  
    describe "Service Fees" do
      it "should report the service fees" do
        @finance_summary.service_fees.gross_fees.should eq 1800
      end
    end
  
    describe "Processing Fees" do
      it "should report the fees" do
        expected_surcharges = 0
        orders.each do |order|
          order.items.each { |item| expected_surcharges += (item.price - item.net) }
        end
        @finance_summary.processing_fees.gross_fees.should eq expected_surcharges
        @finance_summary.processing_fees.num_tickets.should eq 9
        @finance_summary.processing_fees.num_donations.should eq @finance_summary.donations.num_donations
      end
    end
  end
  
  describe "No Orders" do
    it "should report no sales" do
      @finance_summary = FinanceSummary.new([], settlements)
      @finance_summary.all_tickets.gross_sales.should eq 0
    end
  end
  
  describe "No Settlements" do
    it "should report no settlements" do
      @finance_summary = FinanceSummary.new([], [])
      @finance_summary.settlements.net_settlements.should eq 0
      @finance_summary.settlements.num_settlements.should eq 0
    end
  end
end