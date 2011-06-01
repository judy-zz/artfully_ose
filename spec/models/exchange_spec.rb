require 'spec_helper'

describe Exchange do
  let(:order)       { Factory(:athena_order_with_id) }
  let(:items)       { 3.times.collect { Factory(:athena_item) } }
  let(:event)       { Factory(:athena_event_with_id, :organization_id => order.organization.id) }
  let(:tickets)     { 3.times.collect { Factory(:ticket_with_id, :state => "on_sale", :event_id => event.id) } }

  subject { Exchange.new(order, items, tickets) }

  it { should be_valid }

  it "should initialize with an order and items" do
    subject.order.should be order
    subject.items.should be items
  end

  describe "#valid?" do
    it "should not be valid without items" do
      subject.items = []
      subject.should_not be_valid
    end

    it "should not be valid without any tickets" do
      subject.tickets = []
      subject.should_not be_valid
    end

    it "should not be valid if the number of tickets does not match the number of items" do
      subject.items.stub(:length).and_return(2)
      subject.tickets.stub(:length).and_return(3)
      subject.should_not be_valid
    end

    it "should not be valid if any of the items are not returnable" do
      subject.items.first.stub(:exchangeable?).and_return(false)
      subject.should_not be_valid
    end

    it "should not be valid if any of the tickets are comitted" do
      subject.tickets.first.stub(:committed?).and_return(true)
      subject.should_not be_valid
    end

    it "should not be valid if any of the tickets belong to another organization" do
      subject.tickets.first.event_id = Factory(:athena_event_with_id).id
      subject.should_not be_valid
    end
  end

  describe ".submit" do
    describe "return_items" do
      before(:each) do
        subject.stub(:create_athena_order)
      end

      it "should return the items in the exchange" do
        subject.items.each { |item| item.should_receive(:return!).and_return(true) }
        subject.submit
      end
    end

    describe "sell_new_items" do
      before(:each) do
        subject.stub(:return_items).and_return(true)
        subject.stub(:create_athena_order)
      end

      it "should sell each new ticket to the person associated with the order" do
        subject.tickets.each { |ticket| ticket.should_receive(:sell_to) }
        subject.submit
      end

      it "should create an exchange order if all of the tickets are sold successfully" do
        subject.tickets.each { |ticket| ticket.stub(:sell_to).and_return(true) }
        subject.should_receive(:create_athena_order)
        subject.submit
      end
    end
  end
end
