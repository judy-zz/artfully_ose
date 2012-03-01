require 'spec_helper'

describe Exchange do
  disconnect_sunspot  
  let(:order)       { Factory(:order) }
  let(:items)       { 3.times.collect { Factory(:item) } }
  let(:event)       { Factory(:event, :organization => order.organization) }
  let(:tickets)     { 3.times.collect { Factory(:ticket, :state => :on_sale, :organization => order.organization) } }

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
      subject.tickets.first.organization = Factory(:organization)
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
        subject.tickets.each { |ticket| ticket.should_receive(:exchange_to) }
        subject.submit
      end

      it "should post a metric for the exchange" do
        subject.tickets.each { |ticket| RestfulMetrics::Client.should_receive(:add_metric) }
        subject.submit
      end

      it "should create an exchange order if all of the tickets are sold successfully" do
        subject.tickets.each { |ticket| ticket.stub(:exchange_to).and_return(true) }
        subject.should_receive(:create_order)
        subject.submit
      end
    end
  end
end
