require 'spec_helper'

describe Settlement do
  let(:organization) { Factory(:organization) }
  let(:tickets) { 10.times.collect { Factory(:ticket) } }
  let(:show) { Factory(:show, :tickets => tickets) }
  let(:statement) { Statement.for_show(show, organization) }
    
  before(:each) do
    2.times do |i|
      tickets[i].on_sale!
      tickets[i].sell!
    end
  end
  
  it "should report the date of the show" do
    pending
    statement.datetime.should eq show.datetime
  end
  
  it "should report how many tickets were sold" do
    pending
    show.tickets.each do |t|
      puts t.state
      puts t.sold?
    end
    puts show.tickets.where(:state => 'sold').size
    statement.tickets_sold.should eq show.tickets.sold.size
  end
  
  it "should report the gross potential of the show"
  it "should report how many comps were given to the show"
  it "should report the gross as num tickets sold times price of the ticket"
  it "should report processing as 3.5% of the gross"
  it "should report the net as gross - processing"
end