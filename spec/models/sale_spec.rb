require 'spec_helper'

describe Sale do
  disconnect_sunspot
  let(:show){Factory(:show)}
  let(:chart){Factory(:chart_with_sections)}
  let(:quantities) { {chart.sections.first.id.to_s => "2"} }

  subject { Sale.new(show, chart.sections, quantities) }

  describe "non_zero_quantities" do
    let(:quantities) {{chart.sections.first.id.to_s => "0"}}
      
    it "should tell me if they selected any tickets" do
      @empty_sale = Sale.new(show, chart.sections, quantities)
      @empty_sale.non_zero_quantities?.should be_false
    end
  end

  describe "load tickets" do
    before(:each) do
      tix = Array.new(2)
      tix.collect! { Factory(:ticket, :section => chart.sections.first)}
      Ticket.stub(:available).and_return(tix)
    end
    
    it "loads available tickets from a hash of sections" do
      # load_tickets is called in the sale.rb initializer
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
        
    it "creates a new BoxOffice::Checkout and a new BoxOfficeCart" do
      BoxOffice::Checkout.should_receive(:new).and_return(checkout)
      checkout.should_receive(:finish).and_return(true)
      checkout.should_receive(:person).and_return(Factory(:person))
      subject.sell(payment)
    end
  end
end
