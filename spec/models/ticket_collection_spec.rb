require 'spec_helper'

describe TicketCollection do
  before(:each) do
    @collection = TicketCollection.new
    @collection.should be_empty
  end
  it "should be valid without specifying arguemnts during construction" do
    @collection.kind_of?(TicketCollection).should be_true
  end

  it "should store ticket IDs via <<" do
    @collection << 1
    @collection.raw.first.should == 1
  end

  it "should store Tickets via <<" do
    @ticket = Factory(:ticket_with_id)
    @collection << @ticket
    @collection.raw.first.should == @ticket
  end

  it "#first should convert an ID to a Ticket" do
    @ticket = Factory(:ticket, :id => 1)
    FakeWeb.register_uri(:get, "http://localhost/tickets/#{@ticket.id}.json", :status => "200", :body => @ticket.encode)
    @collection << 1
    @collection.first.should == @ticket
    @collection.first.class.should == Ticket
  end

  it "#each should convert any ID to a Ticket" do
    2.times do
      @ticket = Factory(:ticket_with_id)
      @collection << @ticket.id
      FakeWeb.register_uri(:get, "http://localhost/tickets/#{@ticket.id}.json", :status => "200", :body => @ticket.encode)
    end
    @collection << Factory(:ticket_with_id)
    @collection.each do |ticket|
      ticket.class.should == Ticket
    end
  end
end
