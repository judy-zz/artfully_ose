require 'spec_helper'

describe Statement do
  disconnect_sunspot  
  let(:organization)    { FactoryGirl.create(:organization) }
  let(:event)           { FactoryGirl.create(:event) }
  let(:paid_chart)      { FactoryGirl.create(:assigned_chart, :event => event) }
  let(:free_chart)      { FactoryGirl.create(:chart_with_free_sections, :event => event) }
  let(:paid_show)       { FactoryGirl.create(:show_with_tickets, :organization => FactoryGirl.build(:organization), :chart => paid_chart, :event => event) }
  let(:free_show)       { FactoryGirl.create(:show_with_tickets, :organization => FactoryGirl.build(:organization), :chart => free_chart, :event => event) }
  let(:payment)         { FactoryGirl.build(:payment) }
  let(:cart)            { FactoryGirl.create(:cart_with_only_tickets, :tickets => show.tickets[6..8]) }
  
  describe "nil show" do
    it "should return an empty statement if the show is nil" do
      st = Statement.for_show(nil, organization)
      st.should_not be_nil
      st.tickets_sold.should be_nil
    end
  end
  
  describe "free show" do
    let(:tickets)         { free_show.tickets[6..8] }
    let(:cart)            { FactoryGirl.create(:cart_with_only_tickets, :tickets => tickets) }
    let(:checkout)        { Checkout.new(cart, payment) }  
    let(:statement)       { Statement.for_show(free_show, organization) }
    
    before(:each) do
      Person.stub(:find_by_email_and_organization).and_return(FactoryGirl.create(:person))
      checkout.finish
    end
    
    it "should report the date of the show" do
      statement.datetime.should eq free_show.datetime_local_to_event
    end
  
    it "should report how many tickets were sold" do
      statement.tickets_sold.should eq 3
    end
  
    it "should report the potential revenue of the show" do
      statement.potential_revenue.should eq 0
    end
  
    it "should report how many comps were given to the show" do
      statement.tickets_comped.should eq 0
    end
  
    it "should report the gross as num items sold times the gross price of the items" do
      statement.gross_revenue.should eq 0
    end  
    
    it "should report processing as 3.5% of the gross" do
      statement.processing.should eq (0 * 0.035)
    end
  
    it "should report the net as gross - processing" do
      statement.net_revenue.should eq (statement.gross_revenue - statement.processing)
    end  
  end
  
  describe "no tickets sold" do
    let(:tickets)         { paid_show.tickets[6..8] }
    let(:cart)            { FactoryGirl.create(:cart_with_only_tickets, :tickets => tickets) }
    let(:checkout)        { Checkout.new(cart, payment) }  
    let(:statement)       { Statement.for_show(paid_show, organization) }
    
    it "should report the date of the show" do
      statement.datetime.should eq paid_show.datetime
    end
  
    it "should report how many tickets were sold" do
      statement.tickets_sold.should eq 0
    end
  
    it "should report the potential revenue of the show" do
      statement.potential_revenue.should eq 10000
    end
  
    it "should report how many comps were given to the show" do
      statement.tickets_comped.should eq 0
    end
  
    it "should report the gross as num items sold times the gross price of the items" do
      statement.gross_revenue.should eq 0
    end  
    
    it "should report processing as 3.5% of the gross" do
      statement.processing.should eq 0
    end
  
    it "should report the net as gross - processing" do
      statement.net_revenue.should eq (statement.gross_revenue - statement.processing)
    end  
  end
  
  describe "happy path" do
    
    # # TODO: Fix this spec!
    # This whole test is still setup for Athena Payments (see FakeWeb stuff)
    # Needs to be stubbed for active merchant
    # 
    # let(:tickets)         { paid_show.tickets[6..8] }
    # let(:cart)            { FactoryGirl.create(:cart_with_only_tickets, :tickets => tickets) }
    # let(:checkout)        { Checkout.new(cart, payment) }  
    # let(:statement)       { Statement.for_show(paid_show, organization) }
    #   
    # before(:each) do
    #   Person.stub(:find_by_email_and_organization).and_return(FactoryGirl.create(:person))
    #   FakeWeb.register_uri(:post, "http://localhost/payments/transactions/authorize", :body => "{\"success\":true,\"transaction_id\":\"j59qrb\"}")
    #   FakeWeb.register_uri(:post, "http://localhost/payments/transactions/settle", :body => "{\"success\":true }")
    #   
    #   checkout.finish
    #   paid_show.tickets[0..2].each do |t|
    #     t.comp!
    #   end
    # end
    #   
    # it "should report the date of the show" do
    #   statement.datetime.should eq paid_show.datetime
    # end
    #   
    # it "should report how many tickets were sold" do
    #   statement.tickets_sold.should eq 3
    # end
    #   
    # it "should report the potential revenue of the show" do
    #   statement.potential_revenue.should eq 10000
    # end
    #   
    # it "should report how many comps were given to the show" do
    #   statement.tickets_comped.should eq 3
    # end
    #     
    # it "should report the gross as num items sold times the gross price of the items" do
    #   statement.gross_revenue.should eq 3000
    # end  
    # 
    # it "should report processing as 3.5% of the gross" do
    #   statement.processing.should be_within(0.00001).of(3000 * 0.035)
    # end
    #   
    # it "should report the net as gross - processing" do
    #   statement.net_revenue.should eq (statement.gross_revenue - statement.processing)
    # end
  end
end