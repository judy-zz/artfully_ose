require 'spec_helper'

describe Ticket do
  before(:each) do
    FakeWeb.allow_net_connect = false
    Ticket.site = 'http://localhost'
  end

  describe "attributes" do
    before(:each) do
      @ticket = Factory(:ticket)
    end

    it "should include name" do
      @ticket.respond_to?(:name).should be_true
    end

    it "should have name set to 'ticket'" do
      @ticket.attributes.should include(:name)
      @ticket.name.should == 'ticket'
    end

    it "should include EVENT" do
      @ticket.respond_to?(:EVENT).should be_true
    end

    it "should include VENUE" do
      @ticket.respond_to?(:VENUE).should be_true
    end

    it "should include PERFORMANCE" do
      @ticket.respond_to?(:PERFORMANCE).should be_true
    end

    it "should include SOLD" do
      @ticket.respond_to?(:SOLD).should be_true
    end
  end

  describe "#find" do
    it "fetch a ticket by ID" do
      @fake_ticket = Factory(:ticket)
      FakeWeb.register_uri(:get, "http://localhost/tickets/#{@fake_ticket.id}.json", :body => @fake_ticket.encode)
      @ticket = Ticket.find(@fake_ticket.id)
      @ticket.should_not be_nil
      @ticket.should be_valid
    end

    it "should raise ForbiddenAccess when attempting to fetch all tickets" do
      FakeWeb.register_uri(:get, "http://localhost/tickets/.json", :status => "403")
      lambda { Ticket.all }.should raise_error(ActiveResource::ForbiddenAccess)
    end

    it "should raise ResourceNotFound for invalid IDs" do
      FakeWeb.register_uri(:get, "http://localhost/tickets/0.json", :status => ["404", "Not Found"])
      lambda { Ticket.find(0) }.should raise_error(ActiveResource::ResourceNotFound)
    end

    it "should generate a query string for a single parameter search" do
      @ticket = Factory(:ticket, :PRICE => 50)
      FakeWeb.register_uri(:get, "http://localhost/tickets/.json?PRICE=eq50", :body => "[#{@ticket.encode}]" )
      @tickets = Ticket.find(:all, :params => {:PRICE => "eq50"})
      @tickets.map { |ticket| ticket.PRICE.should == 50 }
    end
  end

  describe "#destroy" do
    it "should issue a DELETE when destroying a ticket" do
      @ticket = Factory(:ticket_with_id)
      FakeWeb.register_uri(:delete, "http://localhost/tickets/#{@ticket.id}.json", :status => "204")
      @ticket.destroy

      FakeWeb.last_request.method.should == "DELETE"
      FakeWeb.last_request.path.should == "/tickets/#{@ticket.id}.json"
    end
  end

  describe "#save" do
    it "should issue a PUT when updating a ticket" do
      @ticket = Factory(:ticket_with_id)
      FakeWeb.register_uri(:put, "http://localhost/tickets/#{@ticket.id}.json", :status => "200")
      @ticket.save

      FakeWeb.last_request.method.should == "PUT"
      FakeWeb.last_request.path.should == "/tickets/#{@ticket.id}.json"
    end

    it "should issue a POST when creating a new Ticket" do
      FakeWeb.register_uri(:post, "http://localhost/tickets/.json", :status => "200")
      @ticket = Factory.create(:ticket)

      FakeWeb.last_request.method.should == "POST"
      FakeWeb.last_request.path.should == "/tickets/.json"
    end
  end

  it "should serialize and encode to the JSON format used by ATHENA without an ID" do
    @ticket = Factory.build(:ticket, :EVENT => "Test Ticket")
    @json = { :name => @ticket.name, :props => { :EVENT => "Test Ticket" } }.to_json
    @ticket.encode.should == @json
  end

  it "should serialize and encode to the JSON format used by ATHENA with an ID" do
    @ticket = Factory.build(:ticket_with_id, :EVENT => "Test Ticket")
    @json = { :name => @ticket.name, :id => @ticket.id, :props => { :EVENT => "Test Ticket" } }.to_json
    @ticket.encode.should == @json
  end

  it "should generate tickets given a performance, quantity, and price" do
    FakeWeb.register_uri(:post, "http://localhost/tickets/.json", :status => "200")
    @performance = Factory.build(:performance)
    @tickets = Ticket.generate_for_performance(@performance, 5, 100)
    @tickets.size.should == 5
    @tickets.each do |ticket|
      ticket.PRICE.should == 100
      ticket.VENUE.should == @performance.venue
      ticket.PERFORMANCE.should == @performance.performed_on
      ticket.EVENT.should == @performance.title
    end
  end

  describe "searching"do
    it "by performance" do
      FakeWeb.register_uri(:get, %r|http://localhost/tickets/.json\?|, :status => "200", :body => "[]")
      now = DateTime.now
      params = { :PERFORMANCE => "=#{now.as_json}" }
      Ticket.search(params)
      FakeWeb.last_request.path.should == "/tickets/.json?PERFORMANCE=%3D#{CGI::escape now.as_json}"

    end

    it "should add _limit to the query string when included in the arguments" do
      FakeWeb.register_uri(:get, 'http://localhost/tickets/.json?_limit=10', :status => "200", :body => "[]")
      params = { :limit => "10" }
      Ticket.search(params)
      FakeWeb.last_request.path.should == "/tickets/.json?_limit=10"
    end
  end
end
