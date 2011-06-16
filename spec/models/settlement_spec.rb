require 'spec_helper'

describe Settlement do
  let(:items) do
    10.times.collect do
      mock(:item).tap { |item| item.stub(:net).and_return(1000) }
    end
  end

  let(:bank_account) { Factory(:bank_account) }
  subject { Settlement.new(items, bank_account) }

  it "sums the net from the items" do
    ACH::Request.should_receive(:for).with(10000, bank_account, "Lorem Ipsum memo")
    Settlement.new(items, bank_account)
  end

  describe "#submit" do
    it "submits the request to the ACH API" do
      subject.instance_variable_get(:@request).should_receive(:submit).and_return(true)
      subject.submit
    end
  end

  describe "#range_for" do
    let(:jobs) do
      {
        :monday     => Time.now.beginning_of_week          + 2.hours, # Monday 2AM
        :tuesday    => Time.now.beginning_of_week + 1.day  + 2.hours, # Tuesday 2AM
        :wednesday  => Time.now.beginning_of_week + 2.days + 2.hours, # Wednesday 2AM
        :thursday   => Time.now.beginning_of_week + 3.days + 2.hours, # Thursday 2AM
        :friday     => Time.now.beginning_of_week + 4.days + 2.hours  # Friday 2AM
      }
    end

    it "determines 48 business hours before the beginning of the day; " do
      target = jobs[:thursday].beginning_of_day - 1.week
      Settlement.range_for(jobs[:tuesday]).should eq [ target, target.end_of_day ]

      target = jobs[:wednesday].beginning_of_day - 1.week
      Settlement.range_for(jobs[:monday]).should eq [ target, target.end_of_day ]

      target = jobs[:tuesday].beginning_of_day
      Settlement.range_for(jobs[:friday]).should eq [ target, target.end_of_day ]

      target = jobs[:monday].beginning_of_day
      Settlement.range_for(jobs[:thursday]).should eq [ target, target.end_of_day ]
    end

    it "includes weekend dates if they occur during settlement period" do
      friday = jobs[:friday].beginning_of_day - 1.week
      sunday = friday + 2.days
      Settlement.range_for(jobs[:wednesday]).should eq [ friday, sunday.end_of_day ]
    end
  end
end
