require 'spec_helper'

describe Order do
  before(:each) do
    @order = Factory(:order)
  end

  it "should be in the 'started' state on creation" do
    @order.started?.should be_true
  end

  it "should store a single Transaction" do
    @transaction = Factory(:transaction)
    @order.transaction = @transaction
    @order.transaction.should == @transaction
  end

  it "should raise a TypeError when assining a non-Transaction" do
    lambda { @order.transaction = 5 }.should raise_error(TypeError, "Expecting a Transaction")
  end

  it "should fetch a Transaction from the remote if not set explicitly" do
    @transaction = Factory(:transaction)
    FakeWeb.register_uri(:get, "http://localhost/tickets/transactions/#{@transaction.id}.json", :status => 200, :body => @transaction.to_json)
    @order = Factory(:order, :transaction_id => @transaction.id)
    @order.transaction.should == @transaction
    FakeWeb.last_request.path.should == "/tickets/transactions/#{@transaction.id}.json"
  end

  it "should proxy the tickets locked in the transaction" do
    @transaction = Factory(:transaction, :tickets => [1,2,3])
    @order = Factory(:order, :transaction => @transaction)
    @order.tickets.each do |ticket|
      @transaction.tickets.should include(ticket.id)
    end
  end

  it "should attempt to delete an existing transaction when updated" do
    @order = Factory(:order)
    FakeWeb.register_uri(:delete, "http://localhost/tickets/transactions/#{@order.transaction.id}.json", :status => 200)
    @order.tickets = []
    FakeWeb.last_request.path.should == "/tickets/transactions/#{@order.transaction.id}.json"
    FakeWeb.last_request.method.should == "DELETE"
  end

  it "should create a transaction behind the scenes when tickets are specified" do
    @transaction = Factory(:transaction, :tickets => [1,2])
    FakeWeb.register_uri(:post, "http://localhost/tickets/transactions/.json", :status => 200, :body => @transaction.encode)
    FakeWeb.register_uri(:delete, "http://localhost/tickets/transactions/#{@transaction.id}.json", :status => 200)
    @order = Factory.build(:order, :transaction => @transaction)
    @order.tickets = [1,2]
    @order.tickets.each do |ticket|
      @order.transaction.tickets.should include(ticket.id)
    end
  end
end
