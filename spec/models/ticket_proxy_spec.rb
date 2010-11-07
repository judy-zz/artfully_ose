require 'spec_helper'

describe Athena::Proxy::Ticket do
  it "should store the ID of the ticket it proxies" do
    @proxy = Athena::Proxy::Ticket.new(1)
    @proxy.id.should == 1
  end
end
