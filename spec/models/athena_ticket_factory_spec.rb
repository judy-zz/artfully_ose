require 'spec_helper'

describe AthenaTicketFactory do
  before(:each) do
    @performance = Factory(:show)
    @performance.stub(:build!)
    FakeWeb.register_uri(:put, "http://localhost/athena/ticketfactory/#{@performance.id}.json", :body => @performance.encode )
  end

  it "should create tickets when given a performance" do
    @ticket_factory = AthenaTicketFactory.for_performance(@performance)
  end

  it "should call build on the performance" do
    @performance.should_receive(:build!)
    @ticket_factory = AthenaTicketFactory.for_performance(@performance)
  end
end