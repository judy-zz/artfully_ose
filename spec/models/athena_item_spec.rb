require 'spec_helper'

describe AthenaItem do

  subject { Factory(:athena_item_with_id) }

  %w( order_id product_type product_id price ).each do |attribute|
    it { should respond_to attribute }
    it { should respond_to attribute + "=" }
  end

  it "should not be valid with an invalid product type" do
    subject.product_type = "SomethingElse"
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
    let(:product) { Factory(:ticket_with_id) }
    subject { AthenaItem.for(product) }

    it { should be_an AthenaItem }

    it "references the product passed in" do
      subject.product.should eq product
    end
  end

  describe "#product" do
    it "should find the product using product_type and product_id" do
      subject.instance_variable_set(:@product, nil)
      subject.product_type = "AthenaTicket"
      subject.product_id = 1
      AthenaTicket.should_receive(:find).with(1)
      subject.product

      subject.instance_variable_set(:@product, nil)
      subject.product_type = "Donation"
      subject.product_id = 1
      Donation.should_receive(:find).with(1)
      subject.product
    end
  end

  describe "#product=" do
    let(:product) { Factory(:ticket_with_id) }
    before(:each) { subject.product = product }

    it "sets the product_id to the product.id" do
      subject.product_id.should eq product.id
    end

    it "sets the product_type to the product class" do
      subject.product_type.should eq product.class.to_s
    end

    context "a ticket" do
      let(:ticket) { Factory(:ticket_with_id) }
      before(:each) { subject.product = ticket }

      it "sets the performance_id to the tickets performance id" do
        subject.performance_id.should eq ticket.performance_id
      end

      it "sets the price to the price of the ticket" do
        subject.price.should eq ticket.price
      end

      it "sets the realized price to the price of the ticket less $2 dollars (200)" do
        subject.realized_price.should eq (ticket.price - 200)
      end

      it "sets the net to 3.5% of the realized price" do
        realized = (ticket.price - 200)
        net = (realized - (0.035 * realized)).floor
        subject.net.should eq net
      end
    end

    context "a donation" do
      let(:donation) { Factory(:donation) }
      before(:each) { subject.product = donation }

      it "sets the price to the price of the donation" do
        subject.price.should eq donation.price
      end

      it "sets the realized price to the price of the donation" do
        subject.realized_price.should eq donation.price
      end

      it "sets the net to 3.5% of the realized price" do
        net = (donation.price - (0.035 * donation.price)).floor
        subject.net.should eq net
      end
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
      it "relies on the product" do
        subject.stub(:modified?).and_return(false)

        subject.product.stub(:refundable?).and_return(true)
        subject.should be_refundable

        subject.product.stub(:refundable?).and_return(false)
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
      it "relies on the product" do
        subject.stub(:modified?).and_return(false)

        subject.product.stub(:exchangeable?).and_return(true)
        subject.should be_exchangeable

        subject.product.stub(:exchangeable?).and_return(false)
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
      it "relies on the product" do
        subject.stub(:modified?).and_return(false)

        subject.product.stub(:returnable?).and_return(true)
        subject.should be_returnable

        subject.product.stub(:returnable?).and_return(false)
        subject.should_not be_returnable
      end
    end
  end

  describe ".settle" do
    let(:settlement) { Factory(:settlement_with_id) }
    let(:items) { 3.times.collect { Factory(:athena_item_with_id) } }
    it "marks all items as settled" do
      FakeWeb.register_uri(:put, "http://localhost/orders/items/patch/#{items.collect(&:id).join(',')}", :body => "[]")
      AthenaItem.settle(items, settlement)
      FakeWeb.last_request.method.should eq "PUT"
      FakeWeb.last_request.path.should match /#{items.collect(&:id).join(',')}/
      FakeWeb.last_request.body.should match /#{settlement.id}/
    end

    it "updates the state of each item to settled" do
      FakeWeb.register_uri(:put, "http://localhost/orders/items/patch/#{items.collect(&:id).join(',')}", :body => "[]")
      AthenaItem.settle(items, settlement)
      FakeWeb.last_request.body.should match /"state":"settled"/
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
      it "returns the product to inventory if it is returnable" do
        subject.product.stub(:returnable?).and_return(true)
        subject.product.should_receive(:return!)
        subject.return!
      end

      it "does not return the product if it is not returnble" do
        subject.product.stub(:returnable?).and_return(false)
        subject.product.should_not_receive(:return!)
        subject.return!
      end
    end
  end
end
