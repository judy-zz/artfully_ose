require 'spec_helper'

describe FinanceSummary do
  disconnect_sunspot
  let(:orders)        { 6.times.collect { Factory(:order) } }
  let(:organization)  { Factory(:organization) }

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
    
    @finance_summary = FinanceSummary.new(orders)
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
      @finance_summary.processing_fees.num_tickets.should eq @finance_summary.artfully_tickets.sold
      @finance_summary.processing_fees.num_donations.should eq @finance_summary.donations.num_donations
    end
  end
end