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
    it { should respond_to :items }

    it "should be empty without any items" do
      subject.should be_empty
    end

    it "should return the tickets added via add_tickets" do
      tickets = 2.times.collect { Factory(:ticket_with_id) }
      lock = Factory(:lock, :tickets => tickets.collect {|t| t.id })
      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => lock.encode)
      subject.add_tickets tickets
      subject.tickets.should eq tickets
    end

    it "should have PurchasableTickets when a tickets are added to the order" do
      tickets = 2.times.collect { Factory(:ticket_with_id) }
      lock = Factory(:lock, :tickets => tickets.collect {|t| t.id })
      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => lock.encode)
      subject.add_tickets tickets
      subject.items.each do |item|
        item.should be_a PurchasableTicket
      end
    end

    it "should have the right PurchasableTickets when tickets are added to the order" do
      tickets = 2.times.collect { Factory(:ticket_with_id) }
      lock = Factory(:lock, :tickets => tickets.collect {|t| t.id })
      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => lock.encode)
      subject.add_tickets tickets
      subject.items.each do |item|
        tickets.should include(item.ticket)
      end
    end

    it "should have a Donation when one is added to the order" do
      donation = Factory(:donation)
      subject.donations << donation
      subject.items.should include(donation)
    end
  end

  describe "items" do
    it "should lock the first lockable item when it is added" do
      tickets = 2.times.collect { Factory(:ticket_with_id) }
      lock = Factory(:lock, :tickets => tickets.collect {|t| t.id })
      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => lock.encode)
      subject.add_tickets tickets
      subject.items.first.should be_locked
    end

    it "should collect and lock the lockable items when they are added" do
      tickets = 2.times.collect { Factory(:ticket_with_id) }
      lock = Factory(:lock, :tickets => tickets.collect {|t| t.id })
      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => lock.encode)
      subject.add_tickets tickets
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
      subject.add_tickets tickets
      order = Order.find(subject.id)
      order.items.should be_empty
    end
  end

  describe "and Payments" do
    it "should sum up the price of the tickets via total" do
      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => Factory(:lock).encode)
      subject.add_tickets 2.times.collect { Factory(:ticket_with_id, :price => "100") }
      subject.total.should eq 200
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
      FakeWeb.register_uri(:post, "http://localhost/orders/orders/.json", :body => Factory(:athena_order_with_id).encode)
      FakeWeb.register_uri(:post, "http://localhost/orders/items/.json", :body => Factory(:athena_item).encode)
      FakeWeb.register_uri(:post, "http://localhost/people/actions/.json", :body => Factory(:athena_purchase_action).encode)
      tickets = 2.times.collect { Factory(:ticket_with_id) }
      lock = Factory(:lock, :tickets => tickets.collect {|t| t.id })
      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => lock.encode)
      subject.add_tickets tickets
      subject.items.each { |item| item.stub!(:sold!) }
      subject.items.each { |item| item.stub!(:sold?).and_return(true) }
    end

    it "should be called when the order is approved" do
      subject.stub!(:finish)
      subject.should_receive(:finish)
      subject.approve!
    end

    it "should mark each item as sold" do
      subject.items.each { |item| item.should_receive(:sold!) }
      subject.finish
    end
  end

  describe ".generate_donations" do
    let(:tickets) { 2.times.collect { Factory(:ticket_with_id) } }

    before(:each) do
      @events = tickets.collect do |ticket|
        AthenaEvent.find(ticket.event_id)
      end

      @organizations = @events.collect do |event|
        Organization.find(event.organization_id)
      end

      FakeWeb.register_uri(:post, "http://localhost/tix/meta/locks/.json", :status => 200, :body => Factory(:lock).encode)
    end

    it "should return a donation for the producer of a single ticket in the order" do
      subject.add_tickets tickets
      donations = subject.generate_donations
      donations.each do |donation|
        @organizations.should include donation.organization
      end
    end

    it "should not return any donations if there are no tickets" do
      subject.generate_donations.should be_empty
    end

    it "should return one donation if the tickets are for the same producer" do
      tickets.each { |ticket| ticket.event_id = @events.first.id }
      subject.stub(:tickets).and_return(tickets)
      subject.generate_donations.should have(1).donation
    end
  end
end
