require 'spec_helper'

describe Show do
  disconnect_sunspot  
  subject { Factory(:show) }

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

  it "should not be valid for a time in the past" do
    subject.datetime = Time.now - 1.day
    subject.chart_id = "4"
    subject.should_not be_valid
  end

  it "should not be valid without a chart_id" do
    subject.datetime = Time.now + 1.day
    subject.chart_id = nil
    subject.should_not be_valid
  end
  
  describe "after_save" do
    it "should create the tickets, put them on sale, and be in the unpublished state" do
      @show = Factory(:event).shows.build({ :organization => Factory(:organization), :chart => Factory(:assigned_chart) })
      @show.datetime = DateTime.now + 1.day
      @show.save
      @show.state.should eq "unpublished"
      @show.tickets.should_not be_empty
      @show.tickets.each do |t|
        t.should be_on_sale
      end
    end
  end

  describe "#played" do
    it "should be played if the event is in the past" do
      subject.datetime = Time.now - 1.day
      subject.should be_played
    end

    it "should not be played if the event is in the future" do
      subject.datetime = Time.now + 1.day
      subject.should_not be_played
    end
  end

  describe "#publish" do
    subject { Factory(:show) }

    it "should mark the performance as on sale" do
      subject.publish!
      subject.should be_published
    end
  end

  describe "#unpublish" do
    subject { Factory(:show) }

    it "should work" do
      subject.publish!
      subject.unpublish!
      subject.should be_unpublished
    end
  end

  describe "#free?" do
    it "is free when the event is free" do
      subject.stub(:event).and_return(mock(:event, :free? => true))
      subject.should be_free
    end

    it "is not free when the event is not free" do
      subject.stub(:event).and_return(mock(:event, :free? => false))
      subject.should_not be_free
    end
  end

  describe "bulk edit tickets" do
    subject { Factory(:show_with_tickets) }

    describe "#bulk_on_sale" do
      it "puts all tickets on sale when :all is specified" do
        Ticket.should_receive(:put_on_sale).at_least(:once).with(subject.tickets)
        subject.bulk_on_sale(:all)
      end

      it "can put a ticket on sale that is already on_sale" do
        subject.tickets.first.state = :on_sale
        outcome = subject.bulk_on_sale(subject.tickets.collect(&:id))
        outcome.should_not be true
      end

      it "fails by returning false if any of the tickets can not be put on sale" do
        subject.tickets.first.update_attribute(:state, :comped)
        outcome = subject.bulk_on_sale(subject.tickets.collect(&:id))
        outcome.should be false
      end
    end

    describe "bulk_off_sale" do
      it "takes tickets off sale" do
        Ticket.should_receive(:take_off_sale).with(subject.tickets)
        subject.bulk_off_sale(subject.tickets.collect(&:id))
      end

      it "fails by returning false if any of the tickets can not be taken off sale" do
        subject.tickets.first.state = :off_sale
        subject.tickets.first.save
        outcome = subject.bulk_off_sale(subject.tickets.collect(&:id))
        outcome.should be false
      end
    end

    describe "bulk_delete" do
      it "should return the ids of tickets that were destroyed" do
        rejected_ids = subject.bulk_delete(subject.tickets.collect(&:id))
        rejected_ids.should eq subject.tickets.collect(&:id)
      end
    end
  end
  
  describe "deleting a show" do
    it "is fine if no tickets are created" do
      s = Factory(:show)
      s.should be_destroyable
      s.destroy.should be_true
    end
    
    it "is okay if tickets are created but they are not on sale" do
      s = Factory(:show_with_tickets)
      s.should be_destroyable
      s.destroy.should be_true
    end
    
    it "is allowed even if tickets are on sale" do
      s = Factory(:show_with_tickets)
      s.bulk_on_sale(:all)
      s.should be_destroyable
      s.destroy.should be_true
    end
    
    it "is frowned upon if any tickets have been sold" do
      s = Factory(:show_with_tickets)
      s.bulk_on_sale(:all)
      s.tickets.first.sell_to(Factory(:person))
      s.bulk_off_sale(:all)
      s.should_not be_destroyable
      s.destroy.should be_false
    end
    
    it "is verboten it any tickets have been comped" do      
      s = Factory(:show_with_tickets)
      s.tickets.first.comp_to(Factory(:person))
      s.should_not be_destroyable
      s.destroy.should be_false
    end
    
    it "should also delete all the tickets" do
      s = Factory(:show_with_tickets)
      s.bulk_on_sale(:all)
      s.tickets.each { |t| t.should_receive(:destroy).and_return(true) }
      s.should be_destroyable
      s.destroy.should be_true      
    end
  end

  describe "#event" do
    it "should store the event when one is assigned" do
      event = Factory(:event)
      subject.event = event
      subject.event.should eq event
    end

    it "should store the event id when an event is assigned" do
      event = Factory(:event)
      subject.event = event
      subject.event_id.should eq event.id
    end
  end

  describe "#dup!" do
    before(:each) do
      subject { Factory(:show) }
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

  describe "#live?" do
    it "is considered live when there is a sold ticket" do
      subject.stub(:tickets).and_return(Array.wrap(mock(:ticket, :comped? => false, :sold? => true)))
      subject.should be_live
    end
  end

  describe "#settleables" do
    let(:items) { 10.times.collect{ Factory(:item, :show_id => subject.id) } }
    before(:each) do
      subject.items = items
    end

    it "finds the settleable line items for the performance" do
      subject.settleables.should eq items
    end

    it "rejects line items that have been modified in some way" do
      items.first.state = "returned"
      subject.settleables.should have(9).items
    end

    it "rejects line items that have been settled already" do
      items.first.state = "settled"
      subject.settleables.should have(9).items
    end
  end

  describe ".next_datetime" do
    context "without a starting performance datetime" do
      subject { Show.next_datetime(nil) }
      it "suggests the next available 8 PM" do
        subject.hour.should eq 20
      end
    end

    context "given a starting performance datetime" do
      let(:base) { Time.now.beginning_of_day }
      subject { Show.next_datetime(mock(:performance, :datetime_local_to_event => base)) }

      it { should eq base + 1.day }
    end

    context "given a starting performance datetime in the past" do
      let(:base) { Time.now.beginning_of_day - 1.week }
      subject { Show.next_datetime(mock(:performance, :datetime_local_to_event => base)) }

      it { should eq base + 1.week + 1.day }
    end
  end
end
