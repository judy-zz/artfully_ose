require 'spec_helper'

describe Exchange do
  let(:order)       { Factory(:athena_order_with_id) }
  let(:items)       { 3.times.collect { Factory(:athena_item) } }
  let(:tickets)     { 3.times.collect { Factory(:ticket_with_id) } }

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
  end

  describe ".submit" do
    it "should return the items in the exchange" do
      subject.items.each { |item| item.should_receive(:return_item).and_return(true) }
      subject.submit
    end

    it "should not update the new items if it failed to return the old ones" do
      subject.items.first.stub(:return_item).and_return(false)
      subject.should_not_receive(:update_items)
      subject.submit
    end
  end
end
