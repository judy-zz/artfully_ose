require 'spec_helper'

describe Event do
  subject { Factory(:event) }

  it { should be_valid }

  it { should respond_to :name }
  it { should respond_to :venue }
  it { should respond_to :producer }

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

  describe "#upcoming_shows" do
    it "should default to a limit of 5 performances" do
      subject.shows = 10.times.collect { Factory(:show, :datetime => (DateTime.now + 1.day)) }
      subject.upcoming_shows.should have(5).shows
    end
  
    it "should fetch performances that occur after today at the beginning of the day" do
      test_performances = 3.times.collect { mock(:show, :datetime => (DateTime.now + 1.day)) }
      test_performances += 2.times.collect { mock(:show, :datetime => (DateTime.now - 1.day)) }
      subject.stub(:shows).and_return(test_performances)
      subject.upcoming_shows.should have(3).shows
    end
  end
  
  describe "chart assignment" do
    it "should assign charts to itself"
    it "should assign a free chart"
    it "should assign free charts to itself if the event is free"
    it "should not assign charts that have already been assigned"
    it "should not assign a chart if the event is free and the chart contains paid sections"
  end
  
  describe "#as_widget_json" do
    subject { Factory(:event) }
  
    it "should not include performances that are on sale" do
      subject.shows = 2.times.collect { Factory(:show) }
      subject.shows.first.state = "published"
      subject.stub(:charts).and_return([])
  
      json = JSON.parse(subject.as_widget_json.to_json)
      json["performances"].length.should eq 1
    end
  end
end