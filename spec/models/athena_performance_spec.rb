require 'spec_helper'

describe AthenaPerformance do
  subject { Factory(:athena_performance) }

  it { should be_valid }

  it { should respond_to :event_id }
  it { should respond_to :event }
  it { should respond_to :chart_id }
  it { should respond_to :chart }
  it { should respond_to :datetime }
  it { should respond_to :day_of_week }

  it "should report the day of the week of the performance" do
    subject.day_of_week.should eql subject.datetime.strftime("%a")
  end
  
  describe "create tickets" do
    before(:each) do
      @chart = Factory(:athena_chart)
      @orchestra_section = Factory(:athena_section_orchestra)
      @balcony_section = Factory(:athena_section_balcony)
      @chart.sections = [@balcony_section, @orchestra_section]
      subject.chart = @chart
    end
    
    it "should create tickets" do
      @ticket = Factory(:athena_chart)
      FakeWeb.register_uri(:post, "http://localhost/tix/tickets/.json", :body => @ticket.encode )
      subject.create_tickets
      FakeWeb.last_request.path.should == "/tix/tickets/.json"
    end
    
  
  end

  it "should accept a string as datetime" do
    subject.datetime = '2010-03-03T02:02:02-04:00'
    subject.datetime.kind_of?(DateTime).should be_true
  end
  
  it "should accept a DateTime as datetime" do
    subject.datetime = DateTime.parse('2010-03-03T02:02:02-04:00')
    subject.datetime.kind_of?(DateTime).should be_true
  end

  it "should parse the datetime attribute to a DateTime object" do
    subject.datetime.kind_of?(DateTime).should be_true
  end

  describe "#dup!" do
    before(:each) do
      subject { Factory(:athena_performance) }
      @new_performance = subject.dup!
    end

    it "should not have the same id" do
      nil.should eq @new_performance.id
    end

    it "should have the same event and chart" do
      @new_performance.event_id.should eq subject.event_id
      @new_performance.chart_id.should eq subject.chart_id
    end

    it "should be set for one day in the future" do
      subject.datetime.should eq @new_performance.datetime - 1.day
    end
  end

  it "should return nil if no chart is assigned" do
    subject.chart_id = nil
    nil.should eq subject.chart
  end

  it "should update chart_id when assiging a chart" do
    subject.chart = Factory(:athena_chart, :id => 1)
    subject.chart_id.should eq 1
  end

  it "should raise a TypeError for invalid chart assignment" do
    lambda { subject.chart = "Not a Chart" }.should raise_error(TypeError)
  end

  it "should update event_id when assiging an event" do
    subject.event = Factory(:athena_event, :id => 1)
    subject.event_id.should eq 1
  end

  it "should raise a TypeError for invalid event assignment" do
    lambda { subject.chart = "Not an Event" }.should raise_error(TypeError)
  end
end
