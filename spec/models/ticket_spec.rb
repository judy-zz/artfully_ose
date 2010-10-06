require 'spec_helper'

describe Ticket do
  before(:each) do
    FakeWeb.allow_net_connect = false
    Ticket.site = 'http://localhost'
  end

  describe "#find" do
    it "fetch a ticket by ID" do
      @fake_ticket = Factory(:ticket)
      FakeWeb.register_uri(:get, "http://localhost/tickets/#{@fake_ticket.id}.json", :body => @fake_ticket.to_athena_json)
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
      @ticket = Factory(:ticket, :price => 50)
      FakeWeb.register_uri(:get, "http://localhost/tickets/.json?price=50", :body => "[#{@ticket.to_athena_json}]" )
      @tickets = Ticket.find(:all, :params => {:price => "50"})
      @tickets.map { |ticket| ticket.props.price.should == 50 }
    end
  end

  describe "#destroy" do
    it "should delete a Ticket with a given ID" do
      @ticket = Factory(:ticket)
      FakeWeb.register_uri(:delete, "http://localhost/tickets/#{@ticket.id}.json", :status => "204")
      @ticket.destroy
    end
  end

  describe "#save" do
    it "should save changes to an exisiting Ticket" do
      pending "stories that require this"
    end

    it "should create a new Ticket when saving an new ticket" do
      pending "stories that require this"
    end
  end

  it "should serialize to the JSON format used by ATHENA" do
    @ticket = Factory.build(:ticket, :field => 'value')
    @json = { :id => @ticket.id, :name => @ticket.name, :props => { :field => 'value' } }.to_json
    @ticket.to_athena_json.should == @json
  end
  
  it "should fetch the Ticket schema from ATHENA" do
    fields = []
    10.times { fields << Factory(:field).attributes }
    FakeWeb.register_uri(:get, "http://localhost/tickets/fields/.json", :body => fields.to_json)

    Field.find(:all).each do |field|
      Ticket.schema.should include(field.name)
    end 
  end
end
