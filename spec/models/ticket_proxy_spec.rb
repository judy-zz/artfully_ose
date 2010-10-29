require 'spec_helper'

describe TicketProxy do
  it "should store the ID of the ticket it proxies" do
    @proxy = TicketProxy.new(1)
    @proxy.id.should == 1
  end
end
