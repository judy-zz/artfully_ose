require 'spec_helper'

describe Sale do
  let(:show){Factory(:show)}
  let(:chart){Factory(:chart_with_sections)}
  let(:quantities){{chart.sections.first.id => "2"}}

  subject { Sale.new(show, chart.sections, quantities)}

  describe "requests" do
    it "generates a new Sale::TicketRequest for each section" do
      subject.send(:requests).should have(chart.sections.count).requests
    end

    it "requests available tickets" do
    end
  end

  describe "#fulfilled?" do
    it "is fullfilled when all requets for tickets are fulfilled" do
      requests = 2.times.collect{mock(:request, :fulfilled? => true)}
      subject.stub(:requests).and_return(requests)
      subject.should be_fulfilled
    end

    it "is not fulfilled if any requet is not" do
      requests = 2.times.collect{mock(:request, :fulfilled? => false)}
      subject.stub(:requests).and_return(requests)
      subject.should_not be_fulfilled
    end
  end

  describe "#has_tickets?" do
    it "returns false without tickets" do
      subject.stub(:tickets).and_return([])
      subject.should_not have_tickets
    end

    it "returns true with tickets" do
      subject.stub(:tickets).and_return(Array.wrap(mock(:ticket)))
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
