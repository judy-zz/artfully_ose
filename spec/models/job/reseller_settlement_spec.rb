require 'spec_helper'

describe Job::ResellerSettlement do
  disconnect_sunspot
  describe ".run" do
    let(:organization) { Factory(:organization, :bank_account => Factory(:bank_account)) }
    let(:settlement) { Factory(:reseller_settlement) }
    
    it "should call the methods using a date range" do
      range = (DateTime.now.beginning_of_month.to_date .. DateTime.now.end_of_month.to_date)
      Job::ResellerSettlement.should_receive(:settle_shows_in).with(ResellerSettlement.range_for(DateTime.now))
      Job::ResellerSettlement.run
    end
    
    it "should settle a show on the edge of the date range" do
      settlement.stub(:submit).and_return(nil)
      range = ResellerSettlement.range_for(DateTime.now)   
      show = Factory(:show, :organization => organization, :event => Factory(:event))
      show.datetime = range[0]
      show.save(:validate => false)

      Job::ResellerSettlement.should_receive(:settle_shows_in)
      ResellerSettlement.should_receive(:submit).with(organization.id, show.reseller_settleables, organization.bank_account, show.id).and_return(settlement)
      Job::ResellerSettlement.run
    end
    
    it "should not settle a show outside of the date range" do
      settlement.stub(:submit).and_return(nil)
      range = ResellerSettlement.range_for(DateTime.now)   
      show = Factory(:show, :organization => organization, :event => Factory(:event))
      show.datetime = range[0] - 1.minute
      show.save(:validate => false)

      Job::ResellerSettlement.should_receive(:settle_shows_in)
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
end
