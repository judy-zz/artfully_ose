require File.dirname(__FILE__) + '/../spec_helper'

describe Ticket, "class" do
  before(:each) do
    FakeWeb.allow_net_connect = false
    Ticket.site = 'http://localhost'
  end

  it "should fetch the Ticket schema" do
    pending
    @schema = Factory.build(:schema, :resource => :tickets)
    FakeWeb.register_uri(:get, "http://localhost/#{@schema.resource}/fields", :body => @schema.to_json)
    
    @schema = Ticket.schema
    @schema.should_not be_nil
  end
  
  it "fetch a ticket by ID" do
    @fake_ticket = Factory(:ticket)
    FakeWeb.register_uri(:get, "http://localhost/tickets/#{@fake_ticket.id}.json", :body => @fake_ticket.to_athena_json)
    @ticket = Ticket.find(1)
    @ticket.should_not be_nil
    @ticket.should be_valid
  end
  
  it "should raise ResourceNotFound for invalid IDs" do
    FakeWeb.register_uri(:get, "http://localhost/tickets/0.json", :status => ["404", "Not Found"])
    lambda { Ticket.find(0) }.should raise_error(ActiveResource::ResourceNotFound)
  end

  it "should generate a query string for a single parameter search" do
    @ticket = Factory(:ticket, :price => 50)
    FakeWeb.register_uri(:get, "http://localhost/tickets.json?price=50", :body => "[#{@ticket.to_athena_json}]" )
    @tickets = Ticket.find(:all, :params => {:price => "50"})
    @tickets.map { |ticket| ticket.props.price.should == 50 }
  end

  describe "with basic CRUD operations" do
    it "should delete a Ticket with a given ID" do
      pending
    end

    it "should save changes to an exisiting Ticket" do
      pending
    end

    it "should create a new Ticket when saving an new ticket" do
      pending
    end
  end
end


describe Ticket, "A ticket" do
  before(:each) do
    FakeWeb.allow_net_connect = false
  end

  it "should generate a Schema specifc its own properties" do
    pending
  end

  it "should flatten ATHENA props into attributes" do
    pending
  end

  it "should provide a hash of properties" do
    pending
  end

  it "should allow read access to properties" do
    pending
  end

  it "should allow write access to properties" do
    pending
  end

  it "should save modified properties" do
    pending
  end

  it "should serialize to the JSON format used by ATHENA" do
    @ticket = Factory.build(:ticket, :field => 'value')
    @json = { :id => @ticket.id, :name => @ticket.name, :props => { :field => 'value' } }.to_json
    @ticket.to_athena_json.should == @json
  end

end
