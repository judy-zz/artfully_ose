require 'spec_helper'

describe Statement do
  disconnect_sunspot 
  
  let(:organization)    { FactoryGirl.create(:organization) } 
  let(:event)           { FactoryGirl.create(:event) }
  let(:paid_chart)      { FactoryGirl.create(:assigned_chart, :event => event) }
  let(:free_chart)      { FactoryGirl.create(:chart_with_free_sections, :event => event) }
  let(:paid_show)       { FactoryGirl.create(:show_with_tickets, :organization => organization, :chart => paid_chart, :event => event) }
  let(:free_show)       { FactoryGirl.create(:show_with_tickets, :organization => organization, :chart => free_chart, :event => event) }
  
  describe "nil show" do
    it "should return an empty @statement if the show is nil" do
      st = Statement.for_show(nil, organization)
      st.should_not be_nil
      st.tickets_sold.should be_nil
    end
  end
  
  describe "free show" do     
  end
  
  describe "no tickets sold" do      
    before(:each) do
      @statement = Statement.for_show(paid_show, organization)
    end
      
    it "should calculate everything correctly" do
      @statement.datetime.should eq paid_show.datetime
      @statement.tickets_sold.should eq 0
      @statement.potential_revenue.should eq 10000
      @statement.tickets_comped.should eq 0
      @statement.gross_revenue.should eq 0
      @statement.processing.should be_within(0.00001).of(0)
      @statement.net_revenue.should eq 0
      
      @statement.due.should eq 0
      @statement.settled.should eq 0
      
      @statement.payment_method_rows.length.should eq 0      
    end    
  end
  
  describe "three credit card sales and three comps" do    
    before(:each) do
      setup_show

      @statement = Statement.for_show(paid_show, organization)
    end
      
    it "should calculate everything correctly" do
      @statement.datetime.should eq paid_show.datetime
      @statement.tickets_sold.should eq 3
      @statement.potential_revenue.should eq 10000
      @statement.tickets_comped.should eq 3
      @statement.gross_revenue.should eq 3000
      @statement.processing.should be_within(0.00001).of(3000 * 0.035)
      @statement.net_revenue.should eq (@statement.gross_revenue - @statement.processing)
      
      @statement.due.should eq 2895
      @statement.settled.should eq 0
      
      @statement.payment_method_rows.length.should eq 3
      
      @statement.payment_method_rows[::CreditCardPayment.payment_method].should_not be_nil
      @statement.payment_method_rows[::CreditCardPayment.payment_method].gross.should eq 3000
      @statement.payment_method_rows[::CreditCardPayment.payment_method].processing.should be_within(0.00001).of(3000 * 0.035)
      @statement.payment_method_rows[::CreditCardPayment.payment_method].net.should eq 2895
      
      @statement.payment_method_rows[::CompPayment.payment_method].should_not be_nil
      @statement.payment_method_rows[::CompPayment.payment_method].gross.should eq 0
      @statement.payment_method_rows[::CompPayment.payment_method].processing.should be_within(0.00001).of(0)
      @statement.payment_method_rows[::CompPayment.payment_method].net.should eq 0
      
      @statement.payment_method_rows[::CashPayment.payment_method].should_not be_nil
      @statement.payment_method_rows[::CashPayment.payment_method].gross.should eq 0
      @statement.payment_method_rows[::CashPayment.payment_method].processing.should be_within(0.00001).of(0)
      @statement.payment_method_rows[::CashPayment.payment_method].net.should eq 0
      
    end
  end
  
  describe "with an exchange" do      
    before(:each) do
      setup_show
      settlement = paid_show.settlements.build
      settlement.success = true
      settlement.net = 1000
      settlement.save
      @statement = Statement.for_show(paid_show, organization)
    end
      
    it "should calculate everything correctly" do
      @statement.datetime.should eq paid_show.datetime
      @statement.tickets_sold.should eq 3
      @statement.potential_revenue.should eq 10000
      @statement.tickets_comped.should eq 3
      @statement.gross_revenue.should eq 3000
      @statement.processing.should be_within(0.00001).of(3000 * 0.035)
      @statement.net_revenue.should eq (@statement.gross_revenue - @statement.processing)
      
      @statement.due.should eq 2895
      @statement.settled.should eq 1000
      
      @statement.payment_method_rows.length.should eq 3
      
      @statement.payment_method_rows[::CreditCardPayment.payment_method].should_not be_nil
      @statement.payment_method_rows[::CreditCardPayment.payment_method].gross.should eq 3000
      @statement.payment_method_rows[::CreditCardPayment.payment_method].processing.should be_within(0.00001).of(3000 * 0.035)
      @statement.payment_method_rows[::CreditCardPayment.payment_method].net.should eq 2895
      
    end  
  end
  
  describe "with settlements" do
  end
  
  def setup_show
    0.upto(2) do |i|
      (paid_show.tickets[i]).sell_to(FactoryGirl.create(:person))
      order = FactoryGirl.create(:credit_card_order, :organization => organization)
      order << paid_show.tickets[i]
      order.save
    end
    
    Comp.new(paid_show, paid_show.tickets[3..5], FactoryGirl.create(:person), FactoryGirl.create(:user_in_organization)).submit
  end
end