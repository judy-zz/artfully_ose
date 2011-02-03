require 'spec_helper'

describe AthenaLock do
  before(:each) do
    AthenaLock.site = 'http://localhost/tix/meta/'
  end

  describe "as a remote resource" do
    it "should use the prefix /tix/meta/" do
      FakeWeb.register_uri(:get, "http://localhost/tix/meta/locks/.json", :status => 200, :body => "[]")
      AthenaLock.all
      FakeWeb.last_request.path.should == "/tix/meta/locks/.json"
    end
  end

  describe "attributes" do
    subject { Factory(:lock) }

    it { should be_valid }
    it { should respond_to :tickets }
    it { should respond_to :lock_expires }
    it { should respond_to :locked_by_api }
    it { should respond_to :locked_by_ip }
    it { should respond_to :status }

    it "should parse the lock_expires attribute before validation" do
      FakeWeb.register_uri(:post, 'http://localhost/tix/meta/locks/.json', :status => 200, :body => Factory(:lock).encode)
      lock = AthenaLock.create()
      lock.lock_expires.should be_a_kind_of(DateTime)
    end
  end

  describe "#tickets" do
    it "should be empty when no ticket ids are specified" do
      lock = Factory(:lock)
      lock.tickets.should be_empty
    end

    it "should only accept numerical Ticket IDs" do
      lock = Factory(:lock)
      lock.tickets << "2"
      lock.tickets.size.should == 1
      lock.tickets.first.should == "2"
    end
  end

  it "should not be valid with if lock_expires as passed" do
    lock = Factory(:expired_lock)
    lock.should_not be_valid
  end

  it "should include ticket IDs when encoded" do
    lock = Factory(:lock)
    lock.tickets << "2"
    lock.encode.should =~ /\"tickets\":\[\"2\"\]/
  end
end
