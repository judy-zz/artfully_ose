require 'spec_helper'

describe Settlement do
  let(:organization) { Factory(:organization) }
  let(:tickets) { 10.times.collect { Factory(:ticket) } }
  let(:show) { Factory(:show, :tickets => tickets) }
  let(:statement) { Statement.for_show(show, organization) }
    
  before(:each) do
    sell_tickets
    comp_tickets
  end
  
  it "should return an empty statement if the show is nil" do
    st = Statement.for_show(nil, organization)
    st.should_not be_nil
    st.tickets_sold.should be_nil
  end
  
  it "should report the date of the show" do
    statement.datetime.should eq show.datetime
  end
  
  it "should report how many tickets were sold" do
    statement.tickets_sold.should eq 2
  end
  
  it "should report the potential revenue of the show" do
    statement.potential_revenue.should eq 50000
  end
  
  it "should report how many comps were given to the show" do
    statement.tickets_comped.should eq 3
  end
  
  it "should report the gross as num items sold times the gross price of the items"
  it "should report processing as 3.5% of the gross"
  
  it "should report the net as gross - processing" do
    pending
    statement.net_revenue.should eq statement.gross - statement.processing
  end
  
  def sell_tickets
    2.times do |i|
      tickets[i].on_sale!
      tickets[i].sell!
      tickets[i].save
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