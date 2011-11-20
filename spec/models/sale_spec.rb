require 'spec_helper'

describe Sale do
  let(:show){Factory(:show)}
  let(:chart){Factory(:chart_with_sections)}
  let(:quantities){{chart.sections.first.id.to_s => "2"}}

  subject { Sale.new(show, chart.sections, quantities)}

  describe "#has_tickets?" do
    it "returns false without tickets" do
      subject.should_not have_tickets
    end

    it "returns true with tickets" do
      tix = Array.new(2)
      tix.collect! {Ticket.new}
      Ticket.stub(:available).and_return(tix)
      subject.load_tickets
      subject.should have_tickets
    end
  end

  describe "#cart" do
    it "should create and reuse the same cart" do
      cart = subject.cart
      subject.cart.should == cart
    end
  end

  describe "#sell" do
    let(:order) { mock(:order, :items => []) }

    before(:each) do
      subject.stub(:fulfilled?).and_return(true)
      subject.stub(:tickets).and_return(Array.wrap(mock(:ticket, :id => 1)))
    end

    let(:payment) { mock(:payment, :customer => Factory(:customer_with_id), :amount= => nil, :requires_settlement? => false) }
    it "adds the tickest to the cart" do
      Checkout.stub(:new).and_return(mock(:checkout, :finish => true, :order => order))
      subject.sell(payment)
    end

    it "creates a new Checkout" do
      Checkout.should_receive(:new).and_return(mock(:checkout, :finish => true, :order => order))
      subject.sell(payment)
    end
  end
end
