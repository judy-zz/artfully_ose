require 'spec_helper'

describe AthenaPerformance do
  it "should create tickets when given a performance" do
    @performance = Factory(:athena_performance)
    @performance.id=45
    FakeWeb.register_uri(:put, "http://localhost/tix/meta/ticketfactory/45.json", :body => @performance.encode )
    @ticket_factory = AthenaTicketFactory.for_performance(@performance)
  end
end