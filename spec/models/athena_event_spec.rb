require 'spec_helper'

describe AthenaEvent do
  subject { Factory(:athena_event) }

  it { should be_valid }

  it { should respond_to :name }
  it { should respond_to :venue }
  it { should respond_to :city }
  it { should respond_to :state }
  it { should respond_to :producer }
  it { should respond_to :performances }
  it { should respond_to :charts }

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

  describe "performances" do
    it "should store a list of performances" do
      test_performances = (0..5).collect { Factory(:athena_performance) }
      subject.performances = test_performances
      subject.performances.size.should eq test_performances.size
    end

    it "should fetch the performances from ATHENA if not yet cached" do
      test_performances = (0..1).collect { Factory(:athena_performance) }
      subject.id = 1
      FakeWeb.register_uri(:get, 'http://localhost/stage/performances/.json?eventId=eq1', :status => 200, :body => test_performances.to_json)
      subject.performances.should eq test_performances
    end

    it "should not attempt to fetch performances if the record is not yet saved" do
      subject.should be_new_record
      subject.performances.should eq []
    end

    it "should raise a TypeError for invalid performance assignment" do
      lambda { subject.performances = "Not an Array" }.should raise_error(TypeError)
    end
  end

  describe "charts" do
    it "should store a list of performances" do
      charts = (0..5).collect { Factory(:athena_chart) }
      subject.charts = charts
      subject.charts.size.should eq charts.size
    end

    it "should not attempt to fetch charts if the record is not yet saved" do
      subject.should be_new_record
      subject.charts.should eq []
    end

    it "should fetch the charts from ATHENA if not yet cached" do
      charts = (0..5).collect { Factory(:athena_chart) }
      subject.id = 1
      FakeWeb.register_uri(:get, 'http://localhost/stage/charts/.json?eventId=eq1', :status => 200, :body => charts.to_json)
      subject.charts.size.should eq charts.size
    end

    it "should raise a TypeError for invalid chart assignment" do
      lambda { subject.charts = "Not an Array" }.should raise_error(TypeError)
    end
  end

  describe ".to_widget_json" do
    subject { Factory(:athena_event_with_id) }

    it "should not include performances that are on sale" do
      subject.performances = 2.times.collect { Factory(:athena_performance_with_id) }
      subject.performances.first.on_sale = true
      subject.stub(:charts).and_return([])

      json = JSON.parse(subject.to_widget_json)
      json["performances"].length.should eq 1
    end
  end
end