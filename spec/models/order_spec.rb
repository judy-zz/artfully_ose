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
  end

  describe "#add_tickets" do
    let(:tickets) { 2.times.collect { Factory(:ticket_with_id) } }

    before(:each) do
      subject.stub(:create_lock).and_return(Factory(:lock, :tickets => tickets.collect {|t| t.id }))
      subject.add_tickets tickets
    end

    it "should return the tickets added via add_tickets" do
      subject.tickets.should eq tickets
    end

    it "should have PurchasableTickets when a tickets are added to the order" do
      subject.items.each { |item| item.should be_a PurchasableTicket }
    end

    it "should have the right PurchasableTickets when tickets are added to the order" do
      subject.items.each { |item| tickets.should include(item.ticket) }
    end
  end
  
  describe "ticket fee" do
    let(:tickets) { 2.times.collect { Factory(:ticket_with_id) } }
    
    it "should have a fee of 0 if there are no tickets" do
      subject.fee_in_cents.should eq 0
    end
    
    it "should keep the fee updated while tickets are added" do
      subject.stub(:create_lock).and_return(Factory(:lock, :tickets => tickets.collect {|t| t.id }))
      subject.add_tickets tickets
      subject.fee_in_cents.should eq 400
    end
    
    it "should have a 0 fee if there is a donation" do
      donation = Factory(:donation)
      subject.donations << donation
      subject.fee_in_cents.should eq 0
      subject.stub(:create_lock).and_return(Factory(:lock, :tickets => tickets.collect {|t| t.id }))
      subject.add_tickets tickets
      subject.fee_in_cents.should eq 400
      subject.add_tickets tickets
      subject.fee_in_cents.should eq 800
    end
    
    it "should include the fee in the total" do
      subject.stub(:create_lock).and_return(Factory(:lock, :tickets => tickets.collect {|t| t.id }))
      subject.add_tickets tickets
      subject.fee_in_cents.should eq 400
      subject.total.should eq 6400
    end
  end

  describe "donations" do
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
      FakeWeb.register_uri(:post, "http://localhost/athena/locks.json", :status => 200, :body => lock.encode)
      subject.add_tickets tickets
      subject.items.first.should be_locked
    end

    it "should collect and lock the lockable items when they are added" do
      tickets = 2.times.collect { Factory(:ticket_with_id) }
      lock = Factory(:lock, :tickets => tickets.collect {|t| t.id })
      FakeWeb.register_uri(:post, "http://localhost/athena/locks.json", :status => 200, :body => lock.encode)
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
      FakeWeb.register_uri(:post, "http://localhost/athena/locks.json", :status => 200, :body => lock.encode)
      FakeWeb.register_uri(:delete, "http://localhost/athena/locks/#{lock.id}.json", :status => 200)
      subject.add_tickets tickets
      order = Order.find(subject.id)
      order.items.should be_empty
    end
  end

  describe "#total" do
    let(:items) { 10.times.collect{ mock(:item, :price => 10) }}
    it "should sum up the price of the tickets via total" do
      subject.stub(:items) { items }
      subject.total.should eq 100
    end
  end

  describe "#pay_with" do
    let(:payment) { mock(:payment, :amount => 100) }

    it "saves the order after payment" do
      payment.stub(:requires_authorization?) { false }
      subject.should_receive(:save!)
      subject.pay_with(payment, :settle => false)
    end

    describe "authorization" do
      it "attempt to authorize the payment if required" do
        payment.stub(:requires_authorization?) { true }
        payment.should_receive(:authorize!).and_return(true)
        subject.pay_with(payment, :settle => false)
      end

      it "does not attempt to authorize the payment if it is not required" do
        payment.stub(:requires_authorization?).and_return(false)
        payment.should_not_receive(:authorize!)
        subject.pay_with(payment, :settle => false)
      end
    end

    describe "state transitions" do
      it "should transition to approved when the payment is approved" do
        payment.stub(:requires_authorization?).and_return(true)
        payment.stub(:authorize!).and_return(true)
        subject.pay_with(payment, :settle => false)
        subject.should be_approved
      end

      it "should tranisition to rejected when the Payment is rejected" do
        payment.stub(:requires_authorization?).and_return(true)
        payment.stub(:authorize!).and_return(false)
        subject.pay_with(payment, :settle => false)
        subject.should be_rejected
      end

      it "should transition to approved if no authorization is required for the payment" do
        payment.stub(:requires_authorization?).and_return(false)
        subject.pay_with(payment, :settle => false)
        subject.should be_approved
      end
    end

    describe "settlement" do
      it "should settle immediately when an authorized payment is submitted" do
        payment.stub(:requires_authorization?).and_return(true)
        payment.stub(:authorize!).and_return(true)
        payment.should_receive(:settle!)
        subject.pay_with(payment, :settle => true)
      end
    end
  end

  describe "#finish" do
    it "should mark each item as sold" do
      subject.items.each { |item| item.should_receive(:sell_to) }
      subject.finish(Factory(:athena_person), Time.now)
    end
  end

  describe "organizations" do
    it "includes the organizations for the included donations" do
      donation = Factory(:donation)
      subject.donations << donation
      subject.organizations.should include donation.organization
    end

    it "includes the organizations for the included tickets" do
      Factory(:lock)
      ticket = Factory(:ticket_with_id)
      organization = AthenaEvent.find(ticket.event_id).organization

      subject.add_tickets([ticket])
      subject.organizations.should include organization
    end
  end
  
  describe ".clear_donations" do
    it "should do nothing when there are no donations" do
      donations = subject.clear_donations
      subject.donations.size.should eq 0
      donations.size.should eq 0
    end
    
    it "should clear when there is one donation" do
      donation = Factory(:donation)
      subject.donations << donation
      donations = subject.clear_donations
      subject.donations.size.should eq 0
      donations.size.should eq 1
      donations.first.should eq donation
    end
    
    it "should clear when there are two donations" do
      donation = Factory(:donation)
      donation2 = Factory(:donation)
      subject.donations << donation
      subject.donations << donation2
      donations = subject.clear_donations
      subject.donations.size.should eq 0
      donations.size.should eq 2
      donations.first.should eq donation
      donations[1].should eq donation2
    end
  end

  describe ".generate_donations" do
    let(:tickets) { 2.times.collect { Factory(:ticket_with_id) } }

    before(:each) do
      @events = tickets.collect do |ticket|
        AthenaEvent.find(ticket.event_id)
      end

      @organizations = @events.collect(&:organization)
      @organizations.each do |org|
        org.kits << RegularDonationKit.new(:state => :activated)
      end

      FakeWeb.register_uri(:post, "http://localhost/athena/locks.json", :status => 200, :body => Factory(:lock).encode)
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
