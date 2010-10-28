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

  it "should have access to the tickets locked in the transaction" do
    @transaction = Factory(:transaction, :tickets => [1,2,3])
    @order = Factory(:order, :transaction => @transaction)
    @order.tickets.should == @transaction.tickets
  end
end
