require 'spec_helper'

describe Event do
  subject { FactoryGirl.build(:event) }

  it { should be_valid }

  it { should respond_to :name }
  it { should respond_to :venue }
  it { should respond_to :producer }

  it "should be invalid with an empty name" do
    subject.name = nil
    subject.should_not be_valid
  end

  #The reason this is out is because validating on the venue left the user with a confounding
  #"Venue can't be blank" error message.  When we move to selecting venues from a list, we can re-enable this
  # it "should be invalid for with an empty venue" do
  #   subject.venue = nil
  #   subject.should_not be_valid
  # end
  
  it "should create a chart when the event is created" do
    subject.charts.length.should eq 1
    chart = subject.charts.first
    chart.name.should eq subject.name
    chart.organization.should eq subject.organization
    chart.is_template.should be_false
  end
  
  describe "#upcoming_shows" do
    it "should default to a limit of 5 performances" do
      subject.shows = 10.times.collect { FactoryGirl.build(:show, :datetime => (DateTime.now + 1.day)) }
      subject.upcoming_shows.should have(5).shows
    end
  
    it "should fetch performances that occur after today at the beginning of the day" do
      test_performances = 3.times.collect { mock(:show, :datetime => (DateTime.now + 1.day)) }
      test_performances += 2.times.collect { mock(:show, :datetime => (DateTime.now - 1.day)) }
      subject.stub(:shows).and_return(test_performances)
      subject.upcoming_shows.should have(3).shows
    end
  end
  
  describe "#as_widget_json" do
    subject { FactoryGirl.build(:event) }
  
    it "should not include performances that are on sale" do
      subject.shows = 2.times.collect { FactoryGirl.build(:show) }
      subject.shows.first.build!
      subject.shows.first.publish!
      subject.stub(:charts).and_return([])
      
      json = JSON.parse(subject.as_widget_json.to_json)
      json["performances"].length.should eq 1
    end
  end
end