require 'spec_helper'

describe Order do
  subject { Factory(:order) }

  it "should be marked as unfinished in the started state" do
    subject.state = 'started'
    subject.should be_unfinished
  end

  it "should be marked as unfinished in the rejected state" do
    subject.state = 'rejected'
    subject.should be_unfinished
  end

  describe "with items" do
    it { should respond_to :add_item }
    it { should respond_to :items }

    it "should be empty without any items" do
      subject.should be_empty
    end

    it "should have PurchasableTickets when a tickets are added to the order" do
      tickets = 2.times.collect { Factory(:ticket_with_id) }
      lock = Factory(:lock, :tickets => tickets.collect {|t| t.id })
      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => lock.encode)
      subject.add_items tickets
      subject.items.each do |item|
        item.should be_a PurchasableTicket
      end
    end

    it "should have the right PurchasableTickets when tickets are added to the order" do
      tickets = 2.times.collect { Factory(:ticket_with_id) }
      lock = Factory(:lock, :tickets => tickets.collect {|t| t.id })
      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => lock.encode)
      subject.add_items tickets
      subject.items.each do |item|
        tickets.should include(item.ticket)
      end
    end
  end

  describe "items" do
    it "should lock the first lockable item when it is added" do
      tickets = 2.times.collect { Factory(:ticket_with_id) }
      lock = Factory(:lock, :tickets => tickets.collect {|t| t.id })
      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => lock.encode)
      subject.add_items tickets
      subject.items.first.should be_locked
    end

    it "should collect and lock the lockable items when they are added" do
      tickets = 2.times.collect { Factory(:ticket_with_id) }
      lock = Factory(:lock, :tickets => tickets.collect {|t| t.id })
      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => lock.encode)
      subject.add_items tickets
      lock = subject.items.first.lock
      subject.items.each do | item |
        item.should be_locked
        item.lock.should eq lock
      end
    end

    it "should remove items that are no longer locked" do
      tickets = 2.times.collect { Factory(:ticket_with_id) }
      lock = Factory(:expired_lock, :tickets => tickets.collect {|t| t.id })
      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => lock.encode)
      FakeWeb.register_uri(:delete, "http://localhost/tix/meta/locks/#{lock.id}.json", :status => 200)
      subject.add_items tickets
      order = Order.find(subject.id)
      order.items.should be_empty
    end
  end

  describe "and Payments" do
    it "should sum up the price of the tickets via total" do
      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => Factory(:lock).encode)
      subject.add_item Factory(:ticket_with_id, :price => "100")
      subject.add_item Factory(:ticket_with_id, :price => "33")
      subject.total.should eq 133
    end

    describe "when transitioning state based on the response from ATHENA" do
      before(:each) do
        @payment = Factory(:payment)
      end

      it "should submit the Payment to ATHENA when the payment is confirmed by the user" do
        FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success":true }')
        subject.pay_with(@payment, :settle => false)
        FakeWeb.last_request.method.should == "POST"
        FakeWeb.last_request.path.should == '/payments/transactions/authorize'
      end

      it "should transition to approved when the payment is approved" do
        FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success":true }')
        subject.pay_with(@payment, :settle => false)
        subject.state.should == "approved"
      end

      it "should tranisition to rejected when the Payment is rejected" do
        FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success":false}')
        subject.pay_with(@payment, :settle => false)
        subject.state.should == "rejected"
      end

      it "should settle immediately when an authorized payment is submitted" do
        FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/authorize', :status => 200, :body => '{ "success": true}')
        FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/settle', :status => 200, :body => '{ "success": true}')
        subject.pay_with(@payment)
        FakeWeb.last_request.method.should == "POST"
        FakeWeb.last_request.path.should == '/payments/transactions/settle'
      end
    end
  end

  describe ".finish" do
    before :each do
      tickets = 2.times.collect { Factory(:ticket_with_id) }
      lock = Factory(:lock, :tickets => tickets.collect {|t| t.id })
      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => lock.encode)
      subject.add_items tickets
      subject.items.each { |item| item.stub!(:sold!) }
      subject.items.each { |item| item.stub!(:sold?).and_return(true) }
    end

    it "should mark each item as sold" do
      subject.items.each { |item| item.should_receive(:sold!) }
      subject.finish
    end

    it "clean up left over line items" do
      subject.finish
      subject.items.should be_empty
    end
  end
end
