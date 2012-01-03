require 'spec_helper'

describe Job::Settlement do
  disconnect_sunspot
  describe ".run" do
    let(:organization) { Factory(:organization, :bank_account => Factory(:bank_account)) }
    let(:settlement) { Factory (:settlement) }
    
    it "should call the methods using a date range" do
      Job::Settlement.should_receive(:settle_shows_in).with(Settlement.range_for(DateTime.now))
      Job::Settlement.should_receive(:settle_donations_in).with(Settlement.range_for(DateTime.now))
      Job::Settlement.run
    end
    
    it "should settle a show on the edge of the date range" do
      settlement.stub(:submit).and_return(nil)
      range = Settlement.range_for(DateTime.now)   
      show = Factory(:show, :organization => organization, :event => Factory(:event))
      show.datetime = range[0]
      show.save(:validate => false)

      Job::Settlement.should_receive(:settle_donations_in)
      Settlement.should_receive(:submit).with(organization.id, show.settleables, organization.bank_account, show.id).and_return(settlement)
      Job::Settlement.run
    end
    
    it "should not settle a show outside of the date range" do
      settlement.stub(:submit).and_return(nil)
      range = Settlement.range_for(DateTime.now)   
      show = Factory(:show, :organization => organization, :event => Factory(:event))
      show.datetime = range[0] - 1.minute
      show.save(:validate => false)

      Job::Settlement.should_receive(:settle_donations_in)
      Settlement.should_not_receive(:submit)
      Job::Settlement.run
    end
  end

  describe ".settle_shows_in" do
    let(:organization) { Factory(:organization, :bank_account => Factory(:bank_account)) }
    let(:shows) { 3.times.collect{ Factory(:show, :organization => organization, :event => Factory(:event)) } }
    let(:settlement) { Factory (:settlement) }

    before(:each) do
      settlement.stub(:submit).and_return(nil)
      shows.each { |show| show.stub(:settleables).and_return(5.times.collect{ Factory(:item) } ) }
      Show.stub(:in_range).and_return(shows)
    end

    it "should not settle a show if it is part of a deleted event" do
      shows.first.event.destroy
      shows.reject(&:event_deleted?).each do |show|
        Settlement.should_receive(:submit).with(organization.id, show.settleables, organization.bank_account, show.id).and_return(settlement)
      end
      Job::Settlement.settle_shows_in(Settlement.range_for(DateTime.now))
    end

    it "creates and submit a Settlement for each show" do
      shows.each do |show|
        Settlement.should_receive(:submit).with(organization.id, show.settleables, organization.bank_account, show.id).and_return(settlement)
      end
      Job::Settlement.settle_shows_in(Settlement.range_for(DateTime.now))
    end
  end

  describe ".settle_donations_in" do
    let(:orders) { 2.times.collect { Factory(:order) } }

    let(:donations_for_first_org)   { 2.times.collect{ Factory(:item, :product_type => "Donation")}}
    let(:donations_for_second_org)  { 2.times.collect{ Factory(:item, :product_type => "Donation")}}

    let(:organizations) { 2.times.collect { Factory(:organization, :bank_account => Factory(:bank_account)) } }
    let(:settlement) { mock(:settlement, :submit => nil) }

    before(:each) do
      donations_for_first_org.each { |donation| donation.stub(:order).and_return(orders.first) }
      orders.first.stub(:organization).and_return(organizations.first)
      orders.first.stub(:all_donations).and_return(donations_for_first_org)

      donations_for_second_org.each { |donation| donation.stub(:order).and_return(orders.second) }
      orders.second.stub(:organization).and_return(organizations.second)
      orders.second.stub(:all_donations).and_return(donations_for_second_org)

      Order.stub(:in_range).and_return(orders)
    end

    it "creates and submit a Settlement for each organization for all donations" do
      Settlement.should_receive(:submit).with(organizations.first.id, donations_for_first_org, organizations.first.bank_account).and_return(settlement)
      Settlement.should_receive(:submit).with(organizations.second.id, donations_for_second_org, organizations.second.bank_account).and_return(settlement)
      Job::Settlement.settle_donations_in(Settlement.range_for(DateTime.now))
    end
  end
end
