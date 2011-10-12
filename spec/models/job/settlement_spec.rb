require 'spec_helper'

describe Job::Settlement do
  describe ".run" do
    it "should settle performances for the date range" do
      Job::Settlement.should_receive(:settle_performances_in).with(Settlement.range_for(DateTime.now))
      Job::Settlement.should_receive(:settle_donations_in).with(Settlement.range_for(DateTime.now))
      Job::Settlement.run
    end
  end

  describe ".settle_performances_in" do
    let(:performances) { 3.times.collect{ Factory(:show) } }
    let(:organization) { Factory(:organization, :bank_account => Factory(:bank_account)) }
    let(:settlement) { mock(:settlement, :submit => nil) }

    before(:each) do
      performances.each { |performance| performance.stub(:organization).and_return(organization) }
      performances.each { |performance| performance.stub(:id).and_return("12") }
      performances.each { |performance| performance.stub(:settleables).and_return(5.times.collect{ Factory(:item) } ) }
      Show.stub(:in_range).and_return(performances)
    end

    it "creates and submit a Settlement for each performance" do
      performances.each do |performance|
        Settlement.should_receive(:submit).with(organization.id, performance.settleables, organization.bank_account, performance.id).and_return(settlement)
      end
      Job::Settlement.settle_performances_in(Settlement.range_for(DateTime.now))
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
