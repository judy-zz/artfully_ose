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

  describe "#order" do
    it "should fetch the order form the remote" do
      subject.order.should be_an AthenaOrder
      subject.order.id.should eq subject.order_id
    end

    it "should return nil if the order_id is not set" do
      subject.order = subject.order_id = nil
      subject.order.should be_nil
    end
  end

  describe ".for" do
    let(:item) { Factory(:ticket_with_id) }
    subject { AthenaItem.for(item) }

    it { should be_an AthenaItem }

    it "references the item passed in" do
      subject.item.should eq item
    end
  end

  describe "#item" do
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

  describe "#item=" do
    let(:item) { Factory(:ticket_with_id) }

    before(:each) do
      subject.item = item
    end

    it "sets the item_id to the item.id" do
      subject.item_id = item.id
    end

    it "sets the item_type to the item class" do
      subject.item_type = item.class.to_s
    end

    it "sets the price to the price of the item" do
      subject.price = item.price
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
    context "when already modified" do
      it "is not true if it has already been refunded" do
        subject.stub(:modified?).and_return(true)
        subject.should_not be_refundable
      end
    end

    context "when not yet modified" do
      it "relies on the item" do
        subject.stub(:modified?).and_return(false)

        subject.item.stub(:refundable?).and_return(true)
        subject.should be_refundable

        subject.item.stub(:refundable?).and_return(false)
        subject.should_not be_refundable
      end
    end
  end

  describe "#exchangeable?" do
    context "when already modified" do
      it "is not true if it has already been exchanged" do
        subject.stub(:modified?).and_return(true)
        subject.should_not be_exchangeable
      end
    end

    context "when not yet modified" do
      it "relies on the item" do
        subject.stub(:modified?).and_return(false)

        subject.item.stub(:exchangeable?).and_return(true)
        subject.should be_exchangeable

        subject.item.stub(:exchangeable?).and_return(false)
        subject.should_not be_exchangeable
      end
    end
  end

  describe "#returnable?" do
    context "when already modified" do
      it "is not true if it has already been returned" do
        subject.stub(:modified?).and_return(true)
        subject.should_not be_returnable
      end
    end

    context "when not yet modified" do
      it "relies on the item" do
        subject.stub(:modified?).and_return(false)

        subject.item.stub(:returnable?).and_return(true)
        subject.should be_returnable

        subject.item.stub(:returnable?).and_return(false)
        subject.should_not be_returnable
      end
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
    context "with tickets" do
      it "returns the item to inventory if it is returnable" do
        subject.item.stub(:returnable?).and_return(true)
        subject.item.should_receive(:return!)
        subject.return!
      end

      it "does not return the item if it is not returnble" do
        subject.item.stub(:returnable?).and_return(false)
        subject.item.should_not_receive(:return!)
        subject.return!
      end
    end
  end
end
