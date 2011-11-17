require 'spec_helper'

describe Statement do
  disconnect_sunspot  
  let(:organization) { Factory(:organization) }
  let(:show) { Factory(:show) }
  let(:tickets) { 10.times.collect { Factory(:ticket, :show => show) } }
  let(:payment) { Factory(:payment) }
  let(:cart) { Factory(:cart_with_only_tickets, :tickets => tickets[6..8]) }

  let(:checkout) { Checkout.new(cart, payment) }  
  let(:statement) { Statement.for_show(show, organization) }
  
  describe "nil show" do
    it "should return an empty statement if the show is nil" do
      st = Statement.for_show(nil, organization)
      st.should_not be_nil
      st.tickets_sold.should be_nil
    end
  end
  
  describe "free show" do
    before(:each) do
      tickets.each do |ticket|
        ticket.price = 0
        ticket.on_sale!
      end
      checkout.finish
    end
    
    it "should report the date of the show" do
      statement.datetime.should eq show.datetime_local_to_event
    end
  
    it "should report how many tickets were sold" do
      statement.tickets_sold.should eq 3
    end
  
    it "should report the potential revenue of the show" do
      statement.potential_revenue.should eq 0
    end
  
    it "should report how many comps were given to the show" do
      statement.tickets_comped.should eq 0
    end
  
    it "should report the gross as num items sold times the gross price of the items" do
      statement.gross_revenue.should eq 0
    end  
    
    it "should report processing as 3.5% of the gross" do
      statement.processing.should eq (0 * 0.035)
    end
  
    it "should report the net as gross - processing" do
      statement.net_revenue.should eq (statement.gross_revenue - statement.processing)
    end  
  end
  
  describe "all tickets comped" do
    before(:each) do
      tickets.each do |ticket|
        ticket.on_sale!
        ticket.comp!
        ticket.save
      end
    end
    
    it "should report the date of the show" do
      statement.datetime.should eq show.datetime
    end
  
    it "should report how many tickets were sold" do
      statement.tickets_sold.should eq 0
    end
  
    it "should report the potential revenue of the show" do
      statement.potential_revenue.should eq 50000
    end
  
    it "should report how many comps were given to the show" do
      statement.tickets_comped.should eq 10
    end
  
    it "should report the gross as num items sold times the gross price of the items" do
      statement.gross_revenue.should eq 0
    end  
    
    it "should report processing as 3.5% of the gross" do
      statement.processing.should eq (0 * 0.035)
    end
  
    it "should report the net as gross - processing" do
      statement.net_revenue.should eq (statement.gross_revenue - statement.processing)
    end  
  end
  
  describe "no tickets sold" do
    before(:each) do
      tickets.each do |ticket|
        ticket.save
      end
    end
    
    it "should report the date of the show" do
      statement.datetime.should eq show.datetime
    end
  
    it "should report how many tickets were sold" do
      statement.tickets_sold.should eq 0
    end
  
    it "should report the potential revenue of the show" do
      statement.potential_revenue.should eq 50000
    end
  
    it "should report how many comps were given to the show" do
      statement.tickets_comped.should eq 0
    end
  
    it "should report the gross as num items sold times the gross price of the items" do
      statement.gross_revenue.should eq 0
    end  
    
    it "should report processing as 3.5% of the gross" do
      statement.processing.should eq (0 * 0.035)
    end
  
    it "should report the net as gross - processing" do
      statement.net_revenue.should eq (statement.gross_revenue - statement.processing)
    end  
  end
  
  describe "happy path" do
    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/payments/transactions/authorize", :body => "{ success:true, transaction_id:'j59qrb' }")
      FakeWeb.register_uri(:post, "http://localhost/payments/transactions/settle", :body => "{ success : true }")
      tickets.each do |ticket|
        ticket.on_sale!
      end
      comp_tickets
      checkout.finish
    end
  
    it "should report the date of the show" do
      statement.datetime.should eq show.datetime
    end
  
    it "should report how many tickets were sold" do
      statement.tickets_sold.should eq 3
    end
  
    it "should report the potential revenue of the show" do
      statement.potential_revenue.should eq 50000
    end
  
    it "should report how many comps were given to the show" do
      statement.tickets_comped.should eq 3
    end
  
    it "should report the gross as num items sold times the gross price of the items" do
      statement.gross_revenue.should eq 15000
    end  
    
    it "should report processing as 3.5% of the gross" do
      statement.processing.should eq (15000 * 0.035)
    end
  
    it "should report the net as gross - processing" do
      statement.net_revenue.should eq (statement.gross_revenue - statement.processing)
    end
  end
  
  def comp_tickets
    3.times do |i|
      tickets[i+2].on_sale!
      tickets[i+2].comp!
      tickets[i+2].save
    end  
  end
end