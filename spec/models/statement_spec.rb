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
  end
  
  describe "three credit card sales" do    
    before(:each) do
      0.upto(2) do |i|
        (paid_show.tickets[i]).sell_to(FactoryGirl.create(:person))
        order = FactoryGirl.create(:credit_card_order, :organization => organization)
        order << paid_show.tickets[i]
        order.save
      end
      
      3.upto(5) do |i|
        (paid_show.tickets[i]).comp_to(FactoryGirl.create(:person))
      end
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
      
      @statement.payment_method_hash.should_not be_nil
      
      @statement.payment_method_hash[::CreditCardPayment.payment_method].length.should eq 3
    end
  end
  
  describe "with an exchange" do    
  end
  
  describe "with settlements" do
  end
end