require 'spec_helper'

describe Order do
  subject { Factory(:order) }

  describe "fa_donations" do
    it "creates an order and an item from an fa_donation" do
      pending "FAFS"
      fa_donation = Factory(:fa_donation)
      organization = Factory(:organization)

      stubbed_order = Factory(:order)
      stubbed_order.stub(:save).and_return(stubbed_order)
      stubbed_order.stub(:items).and_return([])
      stubbed_order.should_receive(:save)
      Order.stub(:find_by_fa_id).and_return(nil)
      Order.stub(:new).and_return(stubbed_order)

      order = Order.from_fa_donation(fa_donation, organization)

      order.organization_id.should eq organization.id
      order.price.should eq fa_donation.amount.to_f * 100
      order.created_at.should eq fa_donation.date
      order.first_name.should eq fa_donation.donor.first_name
      order.last_name.should eq fa_donation.donor.last_name
      order.email.should eq fa_donation.donor.email
      order.fa_id.should eq fa_donation.id
      order.should be_valid

      order.items.size.should eq 1
      item = order.items[0]

      item.price.should eq fa_donation.amount.to_f * 100
      item.realized_price.should eq fa_donation.amount.to_f * 100
      item.net.should eq ((fa_donation.amount.to_f * 100) * 0.94)
      item.fs_project_id.should eq fa_donation.fs_project_id
      item.nongift_amount.should eq fa_donation.nongift.to_f * 100
      item.is_noncash.should eq fa_donation.is_noncash
      item.is_stock.should be_false
      item.reversed_at.should eq Time.at(fa_donation.reversed_at)
      item.reversed_note.should eq fa_donation.reversed_note
      item.fs_available_on.should eq fa_donation.fs_available_on
      item.is_anonymous.should eq fa_donation.is_anonymous
    end

    it "updates an order instead of creating a new one" do
      pending
      fa_donation = Factory(:fa_donation)
      fa_donation.nongift_amount = 1234.56
      organization = Factory(:organization)
      stubbed_item = Factory(:fa_item)
      stubbed_order = Factory(:order)
      stubbed_order.stub(:save).and_return(stubbed_order)
      stubbed_order.stub(:items).and_return(Array.wrap(stubbed_item))
      stubbed_order.should_receive(:save)
      stubbed_order.should_not_receive(:create_purchase_action)
      stubbed_order.should_not_receive(:create_donation_actions)
      Order.should_receive(:find_by_fa_id).and_return(stubbed_order)
      Order.should_not_receive(:new)
      Item.should_not_receive(:new)

      order = Order.from_fa_donation(fa_donation, organization)
      order.items.size.should eq 1
    end

    it "returns null if it didn't find an order by fa_id" do
      Order.should_receive(:find).and_return([])
      single_order = Order.find_by_fa_id "400"
      single_order.should be_nil
    end
  end

  describe "payment" do
    it "returns a new Payment based on the transaction ID" do
      subject.payment.should be_an AthenaPayment
      subject.payment.transaction_id.should eq subject.transaction_id
    end
  end

  describe "#save" do
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