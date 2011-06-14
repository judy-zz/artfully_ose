require 'spec_helper'

describe AthenaPerformance do
  subject { Factory(:athena_performance) }

  it { should be_valid }

  it { should respond_to :event_id }
  it { should respond_to :event }
  it { should respond_to :chart_id }
  it { should respond_to :chart }
  it { should respond_to :datetime }

  it "should accept a DateTime as datetime" do
    dt = DateTime.now
    subject.datetime = dt
    subject.datetime.to_datetime.utc.to_s.should == dt.utc.to_s
  end

  it "should parse the datetime attribute to a DateTime object" do
    subject.datetime.should be_a_kind_of(ActiveSupport::TimeWithZone)
  end

  describe "put on sale" do
    subject { Factory(:athena_performance_with_id, :state => "built" ) }

    it "should mark the performance as on sale" do
      subject.put_on_sale!
      subject.should be_on_sale
    end
  end

  describe "take off sale" do
    subject { Factory(:athena_performance_with_id, :state => "on_sale" ) }

    it "should mark the performance as off sale" do
      subject.take_off_sale
      subject.should_not be_on_sale!
    end
  end


  describe "bulk edit tickets" do
    subject { Factory(:athena_performance_with_id) }
    let(:tickets) { 3.times.collect { Factory(:ticket_with_id) } }

    before(:each) do
      subject.stub!(:tickets).and_return(tickets)
    end

    describe "#bulk_on_sale" do
      before(:each) do
        body = tickets.collect(&:encode).join(",").gsub(/off_sale/,'on_sale')
        FakeWeb.register_uri(:put, "http://localhost/tix/tickets/patch/#{tickets.collect(&:id).join(',')}", :body => "[#{body}]")
      end

      it "should put tickets on sale" do
        AthenaTicket.should_receive(:put_on_sale).with(subject.tickets)
        subject.bulk_on_sale(tickets.collect(&:id))
      end

      it "fails by returning false if any of the tickets can not be put on sale" do
        tickets.first.state = :on_sale
        outcome = subject.bulk_on_sale(tickets.collect(&:id))
        outcome.should be false
      end
    end

    describe "bulk_off_sale" do
      before(:each) do
        tickets.each { |ticket| ticket.state = "on_sale" }
        body = tickets.collect(&:encode).join(",").gsub(/on_sale/,'off_sale')
        FakeWeb.register_uri(:put, "http://localhost/tix/tickets/patch/#{tickets.collect(&:id).join(',')}", :body => "[#{body}]")
      end

      it "takes tickets off sale" do
        AthenaTicket.should_receive(:take_off_sale).with(subject.tickets)
        subject.bulk_off_sale(tickets.collect(&:id))
      end

      it "fails by returning false if any of the tickets can not be taken off sale" do
        tickets.first.state = :off_sale
        outcome = subject.bulk_off_sale(tickets.collect(&:id))
        outcome.should be false
      end
    end

    describe "bulk_delete" do
      it "should delete tickets" do
        subject.tickets.each { |ticket| ticket.stub!(:destroy) }
        subject.tickets.each { |ticket| ticket.should_receive(:destroy) }

        subject.bulk_delete(subject.tickets.collect(&:id))
      end

      it "should return the ids of tickets that were destroyed" do
        subject.tickets.first.state = "sold"
        subject.tickets.each { |ticket| ticket.stub!(:destroy).and_return(!ticket.sold?) }

        rejected_ids = subject.bulk_delete(subject.tickets.collect(&:id))
        rejected_ids.should eq subject.tickets.from(1).collect(&:id)
      end
    end
  end

  describe "#event" do
    it "should store the event when one is assigned" do
      event = Factory(:athena_event_with_id)
      subject.event = event
      subject.event.should eq event
    end

    it "should store the event id when an event is assigned" do
      event = Factory(:athena_event_with_id)
      subject.event = event
      subject.event_id.should eq event.id
    end
  end

  describe "#dup!" do
    before(:each) do
      subject { Factory(:athena_performance) }
      @new_performance = subject.dup!
    end

    it "should not have the same id" do
      @new_performance.id.should be_nil
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

  describe "#settleables" do
    let(:items) { 10.times.collect{ Factory(:athena_item, :performance_id => subject.id) } }

    it "finds the settleable line items for the performance" do
      AthenaItem.stub(:find_by_performance_id).and_return(items)
      subject.settleables.should eq items
    end

    it "rejects line items that have been modified in some way" do
      items.first.state = "returned"
      AthenaItem.stub(:find_by_performance_id).and_return(items)
      subject.settleables.should have(9).items
    end
  end

  describe ".in_range" do
    it "composes a GET request for a given set of Time objects" do
      start = Time.now.beginning_of_day
      stop = start.end_of_day
      FakeWeb.register_uri(:get, "http://localhost/stage/performances.json?datetime=gt#{start.xmlschema}&datetime=lt#{stop.xmlschema}", :body => "[]")
      AthenaPerformance.in_range(start, stop)
      FakeWeb.last_request.path.should match(/datetime=gt#{start.xmlschema}&datetime=lt#{stop.xmlschema}/)
    end
  end
end
