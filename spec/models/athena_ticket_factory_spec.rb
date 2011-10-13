require 'spec_helper'

describe TicketFactory do
  before(:each) do
    @performance = Factory(:show)
    @performance.stub(:build!)
  end

  it "should call build on the performance" do
    pending
    @performance.should_receive(:build!)
    @ticket_factory = TicketFactory.for_performance(@performance)
  end
end