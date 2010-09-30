require File.dirname(__FILE__) + '/../spec_helper'

describe Ticket, "The Ticket class" do
  before(:each) do
    FakeWeb.allow_net_connect = false
  end

  it "should fetch the Ticket schema" do
    @schema = Factory.build(:schema, :resource => :tickets)
    FakeWeb.register_uri(:get, "http://localhost/#{@schema.resource}/fields", :body => @schema.to_json)
    
    @schema = Ticket.schema
    @schema.should_not be_nil
  end
  
  it "fetch a ticket by ID" do
    @ticket = Factory.build(:ticket)
    FakeWeb.register_uri(:get, "http://localhost/tickets/#{@ticket.id}.json", :body => @ticket.to_json)
    @ticket = Ticket.find(1)
    @ticket.should be_valid
  end
  
  it "should return nil for invalid IDs" do
    FakeWeb.register_uri(:get, "http://localhost/tickets/0", :status => ["404", "Not Found"])
    @ticket = Ticket.find(0)
    @ticket.should be_nil
  end

  it "should find tickets based on properties" do
    @ticket = Ticket.find(:all, :price => "50")
    @ticket.price.should == 50
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
  end

  it "should provide a hash of properties" do
  end

  it "should allow read access to properties" do
  end

  it "should allow write access to properties" do
  end

  it "should save modified properties" do
  end



end
