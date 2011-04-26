require 'spec_helper'

describe AthenaItem do

  subject { Factory(:athena_item_with_id) }

  %w( order_id item_type item_id price ).each do |attribute|
    it { should respond_to attribute }
    it { should respond_to attribute + "=" }
  end

  it "should not be valid with an invalid item type" do
    subject.item_type = "SomethingElse"
    subject.should_not be_valid
  end

  describe "order" do
    it "should fetch the order form the remote" do
      subject.order.should be_an AthenaOrder
      subject.order.id.should eq subject.order_id
    end

    it "should return nil if the order_id is not set" do
      subject.order = subject.order_id = nil
      subject.order.should be_nil
    end
  end

  describe "item" do
    it "should find the item using item_type and item_id" do
      subject.item_type = "AthenaTicket"
      subject.item_id = 1
      AthenaTicket.should_receive(:find).with(1)
      subject.item

      subject.item_type = "Donation"
      subject.item_id = 1
      Donation.should_receive(:find).with(1)
      subject.item
    end

    it "should return nil if an invalid item type is specified" do
      subject.item_type = "SomethingElse"
      subject.item.should be_nil
    end
  end

  describe "#dup!" do
    it "should create a duplicate item without the id" do
      old_attr = subject.attributes.dup
      old_attr.delete(:id)

      new_attr = subject.dup!.attributes

      old_attr.should eq new_attr
    end
  end

  describe "#refundable?" do
    it "is not refundable if it has already been refunded" do
      subject.state = "refunded"
      subject.should_not be_refundable
    end
  end

  describe "#exchangable?" do
    it "is not exchangable if it has already been refunded" do
      subject.state = "refunded"
      subject.should_not be_exchangable
    end
  end

  describe "#to_refund" do
    it "operates on a duplicate item" do
      subject.to_refund.id.should be_nil
    end

    it "returns an item with the refund price set" do
      subject.to_refund.price.should eq subject.price * -1
    end
  end

  describe "#return!" do
    describe "and tickets" do
      it "returns the ticket to inventory if it has not expired" do
        item = Factory(:ticket_with_id, :performance => DateTime.now + 1.day)
        subject.item = item
        item.should_receive(:return!)
        subject.return!
      end

      it "should not return the ticket to inventory if it has expired" do
        item = Factory(:ticket_with_id, :performance => DateTime.now - 1.day)
        subject.item = item
        item.should_not_receive(:return!)
        subject.return!
      end
    end
  end
end
