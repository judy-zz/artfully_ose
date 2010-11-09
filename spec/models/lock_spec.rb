require 'spec_helper'

describe Athena::Lock do
  before(:each) do
    Athena::Lock.site = 'http://localhost'
  end

  describe "as a remote resource" do
    it "use JsonFormat" do
      Athena::Lock.format.should == ActiveResource::Formats::JsonFormat
    end

    it "should use the prefix /tickets/" do
      FakeWeb.register_uri(:any, "http://localhost/tickets/locks/.json", :status => 200, :body => "[]")
      Athena::Lock.all
      FakeWeb.last_request.path.should == "/tickets/locks/.json"
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
      @transaction = Factory(:lock)
      @transaction.tickets.should be_empty
    end

    it "should only accept numerical Ticket IDs" do
      @transaction = Factory(:lock)
      @transaction.tickets << "2"
      @transaction.tickets.size.should == 1
      @transaction.tickets.first.should == "2"
    end
  end

  it "should not be valid if it does not exist on the remote" do
    # Probably need to rescue from a 404 error.
    pending "fixes on remote"
  end

  it "should not be valid with if lockExpires as passed" do
    pending "validates timeliness"
    @transaction = Factory(:lock, :lockExpires => DateTime.now - 12.hours)
    @transaction.should_not be_valid
  end

  it "should include ticket IDs when encoded" do
    @transaction = Factory(:lock)
    @transaction.tickets << "2"
    @transaction.encode.should =~ /\"tickets\":\[\"2\"\]/
  end
end
