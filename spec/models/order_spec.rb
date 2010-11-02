require 'spec_helper'

describe Order do
  before(:each) do
    @order = Factory.build(:order)
  end

  it "should store a single Transaction" do
    @transaction = Factory(:transaction)
    @order.transaction = @transaction
    @order.transaction.should == @transaction
  end

  it "should raise a TypeError when assigning a non-Transaction" do
    lambda { @order.transaction = 5 }.should raise_error(TypeError, "Expecting a Transaction")
  end

  it "should lazy load a Transaction from the remote if not set explicitly" do
    @transaction = Factory(:transaction)
    FakeWeb.register_uri(:get, "http://localhost/tickets/transactions/#{@transaction.id}.json", :status => 200, :body => @transaction.to_json)
    @order = Factory.build(:order, :transaction_id => @transaction.id)
    @order.transaction.should == @transaction
    FakeWeb.last_request.path.should == "/tickets/transactions/#{@transaction.id}.json"
  end

  describe "a new Order" do
    before(:each) do
      @order = Factory.build(:order_without_transaction)
    end

    it "should be a new record" do
      @order.should be_new_record
    end

    it "should attempt to create a new Transaction before saving" do
      @order = Factory.build(:order_without_transaction)
      @transaction = Factory(:transaction, :tickets => [1,2])
      FakeWeb.register_uri(:post, "http://localhost/tickets/transactions/.json", :status => 200, :body => @transaction.encode)
      @order.tickets = [1,2]
      @order.save
      FakeWeb.last_request.path.should == "/tickets/transactions/.json"
      FakeWeb.last_request.method.should == "POST"
    end

    it "should be invalid if a Transaction could not be created" do
      FakeWeb.register_uri(:post, 'http://localhost/tickets/transactions/.json', :status => 409)
      @order = Factory.build(:order_without_transaction)
      @order.tickets = [1,2]
      @order.should_not be_valid
      @order.save.should be_false
    end
  end

  describe "an existing Order" do
    before(:each) do
      @order = Factory(:order)
    end

    it "should not be a new record" do
      @order.should_not be_new_record
    end

    describe "with an unexpired Transaction" do
      it "should not attempt to create a new transaction if the tickets have not changed" do
        @order = Factory(:order, :transaction => Factory(:unexpired_transaction, :tickets => [1,2]))
        @transaction_id = @order.transaction_id
        @order.tickets = [1,2]
        @order.save
        @order.transaction_id.should == @transaction_id
      end

      it "should attempt to create a new Transaction if the tickets have changed" do
        FakeWeb.register_uri(:post, 'http://localhost/tickets/transactions/.json', :status => 200, :body => Factory(:transaction, :tickets => [3,4]).encode)
        @order = Factory(:order, :transaction => Factory(:unexpired_transaction, :tickets => [1,2]))
        @transaction_id = @order.transaction_id
        @order.tickets = [3,4]
        @order.save
        @order.transaction_id.should_not == @transaction_id
        FakeWeb.last_request.method.should == 'POST'
        FakeWeb.last_request.path.should == '/tickets/transactions/.json'
      end
    end

    describe "with an expired Transaction" do
      it "should attempt to create a new Transaction before saving" do
        @order.save
        FakeWeb.last_request.method.should == 'POST'
        FakeWeb.last_request.path.should == '/tickets/transactions/.json'
      end
    end
  end

  it "should destroy the Transaction when it is destroyed" do
    @transaction_id = @order.transaction_id
    FakeWeb.register_uri(:delete, "http://localhost/tickets/transactions/#{@transaction_id}.json", :status => 200)
    @order.destroy
    FakeWeb.last_request.method.should == "DELETE"
    FakeWeb.last_request.path.should == "/tickets/transactions/#{@transaction_id}.json"
  end
end

describe Order, "and Payments" do
  before(:each) do
    @order = Factory(:order)
  end

  describe "when transitioning to the submitted state" do
    before(:each) do
      @order.state.should == "started"
    end

    it "should respond to submit!" do
      @order.respond_to?(:submit!).should be_true
    end

    it "should transition to submitted when a valid Payment is added" do
      @payment = Factory(:payment)
      @payment.should be_valid
      @order.add_payment(@payment)
      @order.state.should == "submitted"
    end

    it "should not transition to submitted when an invalid Payment is added" do
      @payment = Payment.new
      @payment.should_not be_valid
      @order.add_payment(@payment)
      @order.state.should == "started"
    end
  end

  describe "when transitioning state based on the response from ATHENA" do
    before(:each) do
      @order = Factory(:order, :state => "submitted")
      @order.state.should == "submitted"
    end

    it "should submit the Payment to ATHENA when the payment is confirmed by the user" do
      FakeWeb.register_uri(:post, 'http://localhost/payments/.json', :status => 200, :body => '{ "success":true }')
      @payment = Factory(:payment)
      @payment.should be_valid
      @order.confirm_payment(@payment)
      FakeWeb.last_request.method.should == "POST"
      FakeWeb.last_request.path.should == '/payments/.json'
    end

    it "should transition to approved when the payment is approved" do
      FakeWeb.register_uri(:post, 'http://localhost/payments/.json', :status => 200, :body => '{ "success":true }')
      @payment = Factory(:payment)
      @payment.should be_valid
      @order.confirm_payment(@payment)
      @order.state.should == "approved"
    end

    it "should tranisition to rejected when the Payment is rejected" do
      FakeWeb.register_uri(:post, 'http://localhost/payments/.json', :status => 200, :body => '{ "success":false }')
      @payment = Factory(:payment)
      @payment.should be_valid
      @order.confirm_payment(@payment)
      @order.state.should == "rejected"
    end
  end
end
