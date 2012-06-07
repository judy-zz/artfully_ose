require 'spec_helper'

describe Job::ResellerSettlement do
  disconnect_sunspot
  describe ".run" do
    let(:organization) { Factory(:organization, :bank_account => Factory(:bank_account)) }
    let(:settlement) { Factory(:reseller_settlement) }
    
    it "should call the methods using a date range" do
      range = (DateTime.now.beginning_of_month.to_date .. DateTime.now.end_of_month.to_date)
      Job::ResellerSettlement.should_receive(:settle_shows_in).with(range)
      Job::ResellerSettlement.run
    end
    
    it "should settle a show on the edge of the date range" do
      settlement.stub(:submit).and_return(nil)
      range = ResellerSettlement.range_for(DateTime.now)   
      show = Factory(:show, :organization => organization, :event => Factory(:event))
      show.datetime = range[0]
      show.save(:validate => false)

      Job::ResellerSettlement.should_receive(:settle_donations_in)
      ResellerSettlement.should_receive(:submit).with(organization.id, show.reseller_settleables, organization.bank_account, show.id).and_return(settlement)
      Job::ResellerSettlement.run
    end
    
    it "should not settle a show outside of the date range" do
      settlement.stub(:submit).and_return(nil)
      range = ResellerSettlement.range_for(DateTime.now)   
      show = Factory(:show, :organization => organization, :event => Factory(:event))
      show.datetime = range[0] - 1.minute
      show.save(:validate => false)

      Job::ResellerSettlement.should_receive(:settle_donations_in)
      ResellerSettlement.should_not_receive(:submit)
      Job::ResellerSettlement.run
    end
  end

  describe ".settle_shows_in" do
    let(:organization) { Factory(:organization, :bank_account => Factory(:bank_account)) }
    let(:shows) { 3.times.collect{ Factory(:show, :organization => organization, :event => Factory(:event)) } }
    let(:settlement) { Factory (:reseller_settlement) }

    before(:each) do
      settlement.stub(:submit).and_return(nil)
      shows.each { |show| show.stub(:reseller_settleables).and_return(5.times.collect{ Factory(:item) } ) }
      Show.stub(:in_range).and_return(shows)
    end

    it "should not settle a show if it is part of a deleted event" do
      shows.first.event.destroy
      shows.reject(&:event_deleted?).each do |show|
        ResellerSettlement.should_receive(:submit).with(organization.id, show.reseller_settleables, organization.bank_account, show.id).and_return(settlement)
      end
      Job::ResellerSettlement.settle_shows_in(ResellerSettlement.range_for(DateTime.now))
    end

    it "creates and submit a ResellerSettlement for each show" do
      shows.each do |show|
        ResellerSettlement.should_receive(:submit).with(organization.id, show.reseller_settleables, organization.bank_account, show.id).and_return(settlement)
      end
      Job::ResellerSettlement.settle_shows_in(ResellerSettlement.range_for(DateTime.now))
    end
  end  
  
  describe "when disaster strikes" do
    let(:organization) { Factory(:organization, :bank_account => Factory(:bank_account)) }
    let(:shows) { 3.times.collect{ Factory(:show, :organization => organization, :event => Factory(:event)) } }
    let(:settlement) { Factory (:reseller_settlement) }

    before(:each) do
      ResellerSettlement.should_receive(:submit).exactly(3).times.and_raise(Exception.new)
      shows.each { |show| show.stub(:reseller_settleables).and_return(5.times.collect{ Factory(:item) } ) }
      Show.stub(:in_range).and_return(shows)
    end
    
    it "should recover and continue settling if there is a problem" do
      Job::ResellerSettlement.settle_shows_in(ResellerSettlement.range_for(DateTime.now))
    end
  end

  describe ".settle_donations_in" do
    let(:orders) { 3.times.collect { Factory(:order) } }

    let(:donations_for_first_org)   { 2.times.collect{ Factory(:item, :product_type => "Donation")}}
    let(:donations_for_second_org)  { 2.times.collect{ Factory(:item, :product_type => "Donation")}}

    let(:organizations) { 3.times.collect { Factory(:organization, :bank_account => Factory(:bank_account)) } }
    let(:settlement) { mock(:reseller_settlement, :submit => nil) }

    before(:each) do
      donations_for_first_org.each { |donation| donation.stub(:order).and_return(orders.first) }
      orders.first.stub(:organization).and_return(organizations.first)
      orders.first.stub(:all_donations).and_return(donations_for_first_org)

      donations_for_second_org.each { |donation| donation.stub(:order).and_return(orders.second) }
      orders.second.stub(:organization).and_return(organizations.second)
      orders.second.stub(:all_donations).and_return(donations_for_second_org)

      orders.third.stub(:organization).and_return(organizations.third)
      orders.third.stub(:all_donations).and_return([])

      Order.stub(:in_range).and_return(orders)
    end

    it "creates and submit a ResellerSettlement for each organization for all donations" do
      ResellerSettlement.should_receive(:submit).with(organizations.first.id, donations_for_first_org, organizations.first.bank_account).and_return(settlement)
      ResellerSettlement.should_receive(:submit).with(organizations.second.id, donations_for_second_org, organizations.second.bank_account).and_return(settlement)
      
      #This tests the case where an org has ticket sales in range but no donations.  ResellerSettlement was creating an empty settlement
      ResellerSettlement.should_not_receive(:submit).with(organizations.third.id, [], organizations.third.bank_account)
      
      Job::ResellerSettlement.settle_donations_in(ResellerSettlement.range_for(DateTime.now))
    end 
  end
end
