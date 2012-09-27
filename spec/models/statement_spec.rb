require 'spec_helper'

describe Statement do
  disconnect_sunspot 
  
  let(:organization)    { FactoryGirl.create(:organization) } 
  let(:event)           { FactoryGirl.create(:event) }
  let(:paid_chart)      { FactoryGirl.create(:assigned_chart, :event => event) }
  let(:free_chart)      { FactoryGirl.create(:chart_with_free_sections, :event => event) }
  let(:paid_show)       { FactoryGirl.create(:show_with_tickets, :organization => organization, :chart => paid_chart, :event => event) }
  let(:free_show)       { FactoryGirl.create(:show_with_tickets, :organization => organization, :chart => free_chart, :event => event) }
  
  describe "nil show" do
    it "should return an empty @statement if the show is nil" do
      st = Statement.for_show(nil, organization)
      st.should_not be_nil
      st.tickets_sold.should be_nil
    end
  end
  
  describe "free show" do    
    before(:each) do
      0.upto(2) do |i|
        (free_show.tickets[i]).sell_to(FactoryGirl.create(:person))
      end
      @statement = Statement.for_show(free_show, organization)
    end
    
    it "should calculate everything correctly" do
      @statement.datetime.should eq free_show.datetime_local_to_event
      @statement.tickets_sold.should eq 3
      @statement.potential_revenue.should eq 0
      @statement.tickets_comped.should eq 0
      @statement.gross_revenue.should eq 0
      @statement.processing.should eq (0 * 0.035)
      @statement.net_revenue.should eq (@statement.gross_revenue - @statement.processing)
    end  
  end
  
  describe "no tickets sold" do    
    before(:each) do
      @statement = Statement.for_show(paid_show, organization)
    end
    
    it "should calculate everything correctly" do
      @statement.datetime.should eq paid_show.datetime
      @statement.tickets_sold.should eq 0
      @statement.potential_revenue.should eq 10000
      @statement.tickets_comped.should eq 0
      @statement.gross_revenue.should eq 0
      @statement.processing.should eq 0
      @statement.net_revenue.should eq (@statement.gross_revenue - @statement.processing)
    end  
  end
  
  describe "three ticket sales path" do    
    before(:each) do
      0.upto(2) do |i|
        (paid_show.tickets[i]).sell_to(FactoryGirl.create(:person))
        order = FactoryGirl.create(:order_with_processing_charge, :organization => organization)
        order << paid_show.tickets[i]
        order.save
      end
      
      3.upto(5) do |i|
        (paid_show.tickets[i]).comp_to(FactoryGirl.create(:person))
      end
      @statement = Statement.for_show(paid_show, organization)
    end
      
    it "should calculate everything correctly" do
      @statement.datetime.should eq paid_show.datetime
      @statement.tickets_sold.should eq 3
      @statement.potential_revenue.should eq 10000
      @statement.tickets_comped.should eq 3
      @statement.gross_revenue.should eq 3000
      @statement.processing.should be_within(0.00001).of(3000 * 0.035)
      @statement.net_revenue.should eq (@statement.gross_revenue - @statement.processing)
    end
  end
  
  describe "with an exchange" do    
    before(:each) do
      
      #sell four tickets
      0.upto(3) do |i|
        (paid_show.tickets[i]).sell_to(FactoryGirl.create(:person))
        order = FactoryGirl.create(:order_with_processing_charge, :organization => organization)
        order << paid_show.tickets[i]
        order.save
      end
      
      #exchange one
      exchange_for_ticket = FactoryGirl.create(:ticket, :organization => organization, :show => FactoryGirl.create(:show))
      k = Order.first.items.first.product
      exchange = Exchange.new(Order.first, Order.first.items, Array.wrap(exchange_for_ticket))
      exchange.submit
      
      #comp two more
      5.upto(7) do |i|
        (paid_show.tickets[i]).comp_to(FactoryGirl.create(:person))
      end
      
      @statement = Statement.for_show(Show.find(paid_show.id), organization)
    end
      
    it "should calculate everything correctly" do
      @statement.datetime.should eq paid_show.datetime
      @statement.tickets_sold.should eq 3
      @statement.potential_revenue.should eq 10000
      @statement.tickets_comped.should eq 3
      @statement.gross_revenue.should eq 3000
      @statement.processing.should be_within(0.00001).of(3000 * 0.035)
      @statement.net_revenue.should eq (@statement.gross_revenue - @statement.processing)
    end
  end
end