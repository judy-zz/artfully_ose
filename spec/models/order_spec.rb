require 'spec_helper'

describe Order do
  subject { Factory(:order) }

  describe "payment" do
    it "returns a new Payment based on the transaction ID" do
      subject.payment.should be_an AthenaPayment
      subject.payment.transaction_id.should eq subject.transaction_id
    end
  end

  describe "#save" do
    subject { Factory.build(:order) }
    it "creates a purchase action after save" do
      subject.should_receive(:create_purchase_action)
      subject.save
    end

    it "generates a valid donation action for each donation" do
      pending
      donations = 2.times.collect { Factory(:donation) }
      subject << donations
      actions = subject.send(:create_donation_actions)
      actions.should have(2).donation_actions
      actions.each do |action|
        action.should be_valid
        donations.should include action.subject
      end
    end
  end

  describe "generating athena orders" do
    let(:organization) { Factory(:organization) }
    let(:tickets) { 3.times.collect { Factory(:ticket) } }
    let(:donations) { 2.times.collect { Factory(:donation, :organization => organization) } }

    subject do
      Order.new.tap do |order|
        order.for_organization(organization)
        order << tickets
        order << donations
      end
    end

    it "assigns the organization to the order" do
      subject.organization.should eq organization
    end

    it "creates an item that references each ticket" do
      subject.items.select(&:ticket?).size.should eq tickets.size
      subject.items.select(&:ticket?).each do |item|
        tickets.collect(&:id).should include item.product_id
      end
    end

    it "creates an item that references each donation" do
      subject.items.select(&:donation?).size.should eq donations.size
      subject.items.select(&:donation?).each do |item|
        donations.collect(&:id).should include item.product_id
      end
    end
  end

  describe ".in_range" do
    it "composes a GET request for a given set of Time objects" do
      pending
      start = Time.now.beginning_of_day
      stop = start.end_of_day
      Order.in_range(start, stop)
    end
  end
end