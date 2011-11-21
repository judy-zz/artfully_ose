require 'spec_helper'

describe Sale do
  disconnect_sunspot
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

  describe "load tickets" do
    before(:each) do
      tix = Array.new(2)
      tix.collect! { Factory(:ticket, :section => chart.sections.first)}
      Ticket.stub(:available).and_return(tix)
    end
    
    it "loads available tickets from a hash of sections" do
      subject.load_tickets
      subject.tickets.length.should eq 2
    end
  end

  describe "#sell" do
    let(:order) { mock(:order, :items => []) }

    let(:payment) { mock(:cash_payment, 
                         :customer => Factory(:customer_with_id), 
                         :amount= => nil, 
                         :requires_settlement? => false) }
                         
    let(:checkout) { mock(:checkout, :order => order)}
    
    before(:each) do
      tix = Array.new(2)
      tix.collect! { Factory(:ticket, :section => chart.sections.first)}
      Ticket.stub(:available).and_return(tix)
    end
        
    it "creates a new Checkout and a new BoxOfficeCart" do
      Checkout.should_receive(:new).and_return(checkout)
      checkout.should_receive(:finish).and_return(true)
      subject.sell(payment)
    end
  end
end
