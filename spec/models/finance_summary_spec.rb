require 'spec_helper'

describe FinanceSummary do
  disconnect_sunspot
  describe "All tickets" do
    let(:orders)        { 5.times.collect { Factory(:order) } }
    let(:organization)  { Factory(:organization) }
  
    before(:each) do
      (0..2).each do |i|
        orders[i] << 3.times.collect { Factory(:sold_ticket) }
      end
      
      orders[3] << 2.times.collect { Factory (:free_ticket) }
      orders[4] << 4.times.collect { Factory (:comped_ticket) } 
      orders[4].to_comp!
      
      @finance_summary = FinanceSummary.new(orders)
    end
    
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
end