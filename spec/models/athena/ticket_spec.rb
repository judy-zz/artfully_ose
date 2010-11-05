require 'spec_helper'

describe Athena::Ticket do
  before(:each) do
    Athena::Ticket.site = 'http://localhost'
  end

  describe "attributes" do
    subject { Factory(:ticket) }

    it { should respond_to :name }
    it { should respond_to :event }
    it { should respond_to :venue }
    it { should respond_to :performance }
    it { should respond_to :sold }
    it { should respond_to :price }

    specify { subject.name.should eql('ticket') }
  end

  describe "#find" do
    it "fetch a ticket by ID" do
      @fake_ticket = Factory(:ticket)
      FakeWeb.register_uri(:get, "http://localhost/tickets/#{@fake_ticket.id}.json", :body => @fake_ticket.encode)
      @ticket = Athena::Ticket.find(@fake_ticket.id)
      @ticket.should_not be_nil
      @ticket.should be_valid
    end

    it "should raise ForbiddenAccess when attempting to fetch all tickets" do
      FakeWeb.register_uri(:get, "http://localhost/tickets/.json", :status => "403")
      lambda { Athena::Ticket.all }.should raise_error(ActiveResource::ForbiddenAccess)
    end

    it "should raise ResourceNotFound for invalid IDs" do
      FakeWeb.register_uri(:get, "http://localhost/tickets/0.json", :status => ["404", "Not Found"])
      lambda { Athena::Ticket.find(0) }.should raise_error(ActiveResource::ResourceNotFound)
    end

    it "should generate a query string for a single parameter search" do
      @ticket = Factory(:ticket, :price => 50)
      FakeWeb.register_uri(:get, "http://localhost/tickets/.json?price=eq50", :body => "[#{@ticket.encode}]" )
      @tickets = Athena::Ticket.find(:all, :params => {:price => "eq50"})
      @tickets.map { |ticket| ticket.price.should == 50 }
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

    it "should issue a POST when creating a new Athena::Ticket" do
      FakeWeb.register_uri(:post, "http://localhost/tickets/.json", :status => "200")
      @ticket = Factory.create(:ticket)

      FakeWeb.last_request.method.should == "POST"
      FakeWeb.last_request.path.should == "/tickets/.json"
    end
  end

  it "should generate tickets given a performance, quantity, and price" do
    FakeWeb.register_uri(:post, "http://localhost/tickets/.json", :status => "200")
    @performance = Factory.build(:performance)
    @tickets = Athena::Ticket.generate_for_performance(@performance, 5, 100)
    @tickets.size.should == 5
    @tickets.each do |ticket|
      ticket.price.should == 100
      ticket.venue.should == @performance.venue
      ticket.performance.should == @performance.performed_on
      ticket.event.should == @performance.title
    end
  end

  describe "searching"do
    it "by performance" do
      FakeWeb.register_uri(:get, %r|http://localhost/tickets/.json\?|, :status => "200", :body => "[]")
      now = DateTime.now
      params = { :performance => "eq#{now.as_json}" }
      Athena::Ticket.search(params)
      FakeWeb.last_request.path.should == "/tickets/.json?performance=eq#{CGI::escape now.as_json}"

    end

    it "should add _limit to the query string when included in the arguments" do
      FakeWeb.register_uri(:get, 'http://localhost/tickets/.json?_limit=10', :status => "200", :body => "[]")
      params = { :limit => "10" }
      Athena::Ticket.search(params)
      FakeWeb.last_request.path.should == "/tickets/.json?_limit=10"
    end
  end
end
