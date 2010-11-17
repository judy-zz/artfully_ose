require 'spec_helper'

describe Order do
  before(:each) do
    @order = Factory.build(:order)
  end

  it "should store a single Lock" do
    @lock = Factory(:lock)
    @order.lock = @lock
    @order.lock.should == @lock
  end

  it "should be marked as unfinished in the started state" do
    @order.state = 'started'
    @order.should be_unfinished
  end

  it "should be marked as unfinished in the rejected state" do
    @order.state = 'rejected'
    @order.should be_unfinished
  end

  it "should raise a TypeError when assigning a non-Lock" do
    lambda { @order.lock = 5 }.should raise_error(TypeError, "Expecting an AthenaLock")
  end

  it "should lazy load a Lock from the remote if not set explicitly" do
    @lock = Factory(:lock)
    FakeWeb.register_uri(:get, "http://localhost/tix/meta/locks/#{@lock.id}.json", :status => 200, :body => @lock.to_json)
    @order = Factory.build(:order, :lock_id => @lock.id)
    @order.lock.should == @lock
    FakeWeb.last_request.path.should == "/tix/meta/locks/#{@lock.id}.json"
  end

  describe "a new Order" do
    before(:each) do
      @order = Factory.build(:order_without_lock)
    end

    it "should be a new record" do
      @order.should be_new_record
    end

    it "should attempt to create a new Lock before saving" do
      @order = Factory.build(:order_without_lock)
      @lock = Factory(:lock, :tickets => [1,2])
      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => @lock.encode)
      @order.tickets = [1,2]
      @order.save
      FakeWeb.last_request.path.should == "/tix/meta/locks/.json"
      FakeWeb.last_request.method.should == "POST"
    end

    it "should be invalid if a Lock could not be created" do
      FakeWeb.register_uri(:post, 'http://localhost/tix/meta/locks/.json', :status => 409)
      @order = Factory.build(:order_without_lock)
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

    describe "with an unexpired Lock" do
      it "should not attempt to create a new lock if the tickets have not changed" do
        @order = Factory(:order, :lock => Factory(:unexpired_lock, :tickets => [1,2]))
        @lock_id = @order.lock_id
        @order.tickets = [1,2]
        @order.save
        @order.lock_id.should == @lock_id
      end

      it "should attempt to create a new Lock if the tickets have changed" do
        FakeWeb.register_uri(:post, 'http://localhost/tix/meta/locks/.json', :status => 200, :body => Factory(:lock, :tickets => [3,4]).encode)
        @order = Factory(:order, :lock => Factory(:unexpired_lock, :tickets => [1,2]))
        @lock_id = @order.lock_id
        @order.tickets = [3,4]
        @order.save
        @order.lock_id.should_not == @lock_id
        FakeWeb.last_request.method.should == 'POST'
        FakeWeb.last_request.path.should == '/tix/meta/locks/.json'
      end
    end

    describe "with an expired Lock" do
      it "should attempt to create a new Lock before saving" do
        @order.save
        FakeWeb.last_request.method.should == 'POST'
        FakeWeb.last_request.path.should == '/tix/meta/locks/.json'
      end
    end
  end

  it "should destroy the Lock when it is destroyed" do
    @lock_id = @order.lock_id
    FakeWeb.register_uri(:delete, "http://localhost/tix/meta/locks/#{@lock_id}.json", :status => 200)
    @order.destroy
    FakeWeb.last_request.method.should == "DELETE"
    FakeWeb.last_request.path.should == "/tix/meta/locks/#{@lock_id}.json"
  end
end

describe Order, "and Payments" do
  before(:each) do
    @order = Factory(:order)
  end

  it "should sum up the price of the tickets via total" do
    @ticket1 = Factory(:ticket, :id => 1, :price => "100")
    @ticket2 = Factory(:ticket, :id => 2, :price => "33")
    FakeWeb.register_uri(:get, "http://localhost/tix/tickets/#{@ticket1.id}.json", :status => 200, :body => @ticket1.encode)
    FakeWeb.register_uri(:get, "http://localhost/tix/tickets/#{@ticket2.id}.json", :status => 200, :body => @ticket2.encode)
    @order.tickets = [1,2]
    @order.total.should == @ticket1.price.to_i + @ticket2.price.to_i
  end

  describe "when transitioning state based on the response from ATHENA" do
    before(:each) do
      @payment = Factory(:payment)
    end

    it "should submit the Payment to ATHENA when the payment is confirmed by the user" do
      FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success":true }')
      @order.pay_with(@payment, :settle => false)
      FakeWeb.last_request.method.should == "POST"
      FakeWeb.last_request.path.should == '/payments/transactions/authorize'
    end

    it "should transition to approved when the payment is approved" do
      FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success":true }')
      @order.pay_with(@payment, :settle => false)
      @order.state.should == "approved"
    end

    it "should tranisition to rejected when the Payment is rejected" do
      FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success":false}')
      @order.pay_with(@payment, :settle => false)
      @order.state.should == "rejected"
    end

    it "should settle immediately when an authorized payment is submitted" do
      FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success": true}')
      FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/settle', :status => 200, :body => '{ "success": true}')
      @order.pay_with(@payment)
      FakeWeb.last_request.method.should == "POST"
      FakeWeb.last_request.path.should == '/payments/transactions/settle'
    end
  end
end
