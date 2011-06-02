require 'spec_helper'

describe Payout do
  subject { Payout.new }
  let(:jobs) do
    {
      :monday     => Time.now.beginning_of_week          + 2.hours, # Monday 2AM
      :tuesday    => Time.now.beginning_of_week + 1.day  + 2.hours, # Tuesday 2AM
      :wednesday  => Time.now.beginning_of_week + 2.days + 2.hours, # Wednesday 2AM
      :thursday   => Time.now.beginning_of_week + 3.days + 2.hours, # Thursday 2AM
      :friday     => Time.now.beginning_of_week + 4.days + 2.hours  # Friday 2AM
    }
  end

  describe "#range_for" do
    it "determines 48 business hours before the beginning of the day; " do
      target = jobs[:thursday].beginning_of_day - 1.week
      subject.range_for(jobs[:tuesday]).should eq [ target, target.end_of_day ]

      target = jobs[:wednesday].beginning_of_day - 1.week
      subject.range_for(jobs[:monday]).should eq [ target, target.end_of_day ]

      target = jobs[:tuesday].beginning_of_day
      subject.range_for(jobs[:friday]).should eq [ target, target.end_of_day ]

      target = jobs[:monday].beginning_of_day
      subject.range_for(jobs[:thursday]).should eq [ target, target.end_of_day ]
    end

    it "includes weekend dates if they occur during settlement period" do
      friday = jobs[:friday].beginning_of_day - 1.week
      sunday = friday + 2.days
      subject.range_for(jobs[:wednesday]).should eq [ friday, sunday.end_of_day ]
    end
  end

  describe "#performances" do
    let(:time) { Time.now - 3.days }
    let(:performances) { 3.times.collect { Factory(:athena_performance_with_id, :datetime => time) } }

    before(:each) do
      body = performances.collect(&:encode).join(",")
      start = time.beginning_of_day.xmlschema
      stop = time.end_of_day.xmlschema
      FakeWeb.register_uri(:get, "http://localhost/stage/performances.json?datetime=gt#{start}&datetime=lt#{stop}", :body => "[#{body}]")
    end

    it "will request performances within the given range" do
      subject.performances.should eq performances
    end
  end
end
