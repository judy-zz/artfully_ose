require 'spec_helper'

describe Transaction do
  before(:each) do
    FakeWeb.allow_net_connect = false
    Transaction.site = 'http://localhost'
  end


  describe "as a remote resource" do
    it "use JsonFormat" do
      Transaction.format.should == ActiveResource::Formats::JsonFormat
    end

    it "should use the prefix /tickets/" do
      FakeWeb.register_uri(:any, "http://localhost/tickets/transactions/.json", :status => 200, :body => "[]")
      Transaction.all
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

    it "should allow for tickets to be appended via tickets<<" do
      @transaction = Factory(:transaction)
      @transaction.tickets.should be_empty

      @ticket = Factory(:ticket)
      @transaction.tickets << @ticket
      @transaction.tickets.size.should == 1
      @transaction.tickets.first.should == @ticket
    end
  end

  it "should include ticket IDs when encoded" do
    @transaction = Factory(:transaction)
    @ticket = Factory(:ticket_with_id)
    @transaction.tickets << @ticket

    @transaction.encode.should =~ /{\"tickets\":\[\"#{@ticket.id}\"\]}/
  end


end
