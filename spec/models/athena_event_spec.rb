require 'spec_helper'

describe AthenaEvent do
  subject { Factory(:athena_event) }

  it { should be_valid }

  it { should respond_to :name }
  it { should respond_to :venue }
  it { should respond_to :producer }
  it { should respond_to :chart_id }
  it { should respond_to :chart }

  it "should be invalid with an empty name" do
    subject.name = nil
    subject.should_not be_valid
  end

  it "should be invalid for with an empty venue" do
    subject.venue = nil
    subject.should_not be_valid
  end

  it "should be invalid for with an empty producer" do
    subject.producer = nil
    subject.should_not be_valid
  end

  it "should update chart_id when assiging a chart" do
    subject.chart = Factory(:athena_chart, :id => 1)
    subject.chart_id.should eq 1
  end

  it "should raise a TypeError for invalid chart assignment" do
    lambda { subject.chart = "Not a Chart" }.should raise_error(TypeError)
  end
end
