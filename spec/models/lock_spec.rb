require 'spec_helper'

describe Athena::Lock do
  before(:each) do
    Athena::Lock.site = 'http://localhost/tix/meta/'
  end

  describe "as a remote resource" do
    it "use JsonFormat" do
      Athena::Lock.format.should == ActiveResource::Formats::JsonFormat
    end

    it "should use the prefix /tix/meta/" do
      FakeWeb.register_uri(:any, "http://localhost/tix/meta/locks/.json", :status => 200, :body => "[]")
      Athena::Lock.all
      FakeWeb.last_request.path.should == "/tix/meta/locks/.json"
    end
  end

  describe "attributes" do
    subject { Factory(:lock) }

    it { should respond_to :tickets     }
    it { should respond_to :lockExpires }
    it { should respond_to :lockedByApi }
    it { should respond_to :lockedByIp  }
    it { should respond_to :status      }
  end

  describe "#tickets" do
    it "should be empty when no ticket ids are specified" do
      @lock = Factory(:lock)
      @lock.tickets.should be_empty
    end

    it "should only accept numerical Ticket IDs" do
      @lock = Factory(:lock)
      @lock.tickets << "2"
      @lock.tickets.size.should == 1
      @lock.tickets.first.should == "2"
    end
  end

  it "should not be valid if it does not exist on the remote" do
    # Probably need to rescue from a 404 error.
    pending "fixes on remote"
  end

  it "should not be valid with if lockExpires as passed" do
    pending "validates timeliness"
    @lock = Factory(:lock, :lockExpires => DateTime.now - 12.hours)
    @lock.should_not be_valid
  end

  it "should include ticket IDs when encoded" do
    @lock = Factory(:lock)
    @lock.tickets << "2"
    @lock.encode.should =~ /\"tickets\":\[\"2\"\]/
  end
end
