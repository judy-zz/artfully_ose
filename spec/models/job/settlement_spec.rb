require 'spec_helper'

describe Job::Settlement do
  describe ".run" do
    it "should settle performances for the date range" do
      Job::Settlement.should_receive(:settle_performances_in).with(Settlement.range_for(DateTime.now))
      Job::Settlement.run
    end
  end

  describe ".settle_performances_in" do
    let(:performances) { 3.times.collect{ Factory(:athena_performance_with_id) } }
    let(:organization) { Factory(:organization, :bank_account => Factory(:bank_account)) }
    let(:settlement) { mock(:settlement, :submit => nil) }

    before(:each) do
      performances.each { |performance| performance.stub(:organization).and_return(organization) }
      performances.each { |performance| performance.stub(:settleables).and_return(5.times.collect{ Factory(:athena_item) } ) }
      AthenaPerformance.stub(:in_range).and_return(performances)
    end

    it "creates and submit a Settlement for each performance" do
      performances.each do |performance|
        Settlement.should_receive(:new).with(performance.settleables, organization.bank_account).and_return(settlement)
      end
      Job::Settlement.settle_performances_in(Settlement.range_for(DateTime.now))
    end
  end
end
