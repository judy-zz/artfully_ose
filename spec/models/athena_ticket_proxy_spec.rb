require 'spec_helper'

describe AthenaTicketProxy do
  it "should store the ID of the ticket it proxies" do
    @proxy = AthenaTicketProxy.new(1)
    @proxy.id.should == 1
  end
end
