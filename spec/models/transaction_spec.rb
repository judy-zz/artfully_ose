require 'spec_helper'

describe Athena::Transaction do
  before(:each) do
    Athena::Transaction.site = 'http://localhost'
  end

  describe "as a remote resource" do
    it "use JsonFormat" do
      Athena::Transaction.format.should == ActiveResource::Formats::JsonFormat
    end

    it "should use the prefix /tickets/" do
      FakeWeb.register_uri(:any, "http://localhost/tickets/transactions/.json", :status => 200, :body => "[]")
      Athena::Transaction.all
      FakeWeb.last_request.path.should == "/tickets/transactions/.json"
    end
  end

  describe "attributes" do
    before(:each) do
      @transaction = Factory(:transaction)
    end

    it "should include tickets" do
      @transaction.respond_to?(:tickets).should be_true
    end

    it "should include lockExpires" do
      @transaction.respond_to?(:lockExpires).should be_true
    end

    it "should include lockedByApi" do
      @transaction.respond_to?(:lockedByApi).should be_true
    end

    it "should include lockedByIp" do
      @transaction.respond_to?(:lockedByIp).should be_true
    end

    it "should include status" do
      @transaction.respond_to?(:status).should be_true
    end
  end

  describe "#tickets" do
    it "should be empty when no ticket ids are specified" do
      @transaction = Factory(:transaction)
      @transaction.tickets.should be_empty
    end

    it "should only accept numerical Ticket IDs" do
      @transaction = Factory(:transaction)
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
    @transaction = Factory(:transaction, :lockExpires => DateTime.now - 12.hours)
    @transaction.should_not be_valid
  end

  it "should include ticket IDs when encoded" do
    @transaction = Factory(:transaction)
    @transaction.tickets << "2"
    @transaction.encode.should =~ /\"tickets\":\[\"2\"\]/
  end
end
