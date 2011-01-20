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
    subject.day_of_week.should eql subject.datetime.strftime("%A")
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

  describe "take off sale" do
    before(:each) do
      @performance = Factory(:athena_performance_with_id)
      @test_tickets = (0..10).collect { Factory(:ticket_with_id) }
      FakeWeb.register_uri(:get, "http://localhost/tix/tickets/.json?performanceId=eq#{@performance.id}", :status => 200, :body => @test_tickets.to_json)
      FakeWeb.register_uri(:put, "http://localhost/stage/performances/#{@performance.id}.json", :status => 200, :body => @performance.to_json)

      @tickets_hash = {}
      @test_tickets.each { |ticket| @tickets_hash[ticket.id.to_i] = ticket }

      @performance.tickets
    end
    it "should mark the performance as off sale" do
      @test_tickets.each do |t|
        id = t.id.to_i
        FakeWeb.register_uri(:put, "http://localhost/tix/tickets/#{id}.json", :status => 200, :body => @tickets_hash[id].to_json)
      end
      @performance.take_off_sale
      @performance.on_sale?.should be_false
    end
  end
  
  describe "bulk edit tickets" do
    before(:each) do
      @num_tickets_to_test = 3
      @test_tickets = (0..10).collect { Factory(:ticket_with_id) }
      
      #grab three ids at random
      @ticket_ids = []
      @test_tickets.sort_by{ rand }.slice(0...@num_tickets_to_test).each { |t| @ticket_ids << t.id.to_i }
      
      #now hash the tickets by id so we can compare them later
      @tickets_hash = {}
      @test_tickets.each { |ticket| @tickets_hash[ticket.id.to_i] = ticket }
      
      #create a performance
      @performance = Factory(:athena_performance_with_id)
      
      #now hydrate the fake tickets into our performance
      FakeWeb.register_uri(:get, "http://localhost/tix/tickets/.json?performanceId=eq#{@performance.id}", :status => 200, :body => @test_tickets.to_json)
      @performance.tickets
    end
    
    it "should put tickets on sale" do
      @ticket_ids.each do |id|
        FakeWeb.register_uri(:put, "http://localhost/tix/tickets/#{id}.json", :status => 200, :body => @tickets_hash[id].to_json)
      end
      
      @performance.bulk_edit_tickets(@ticket_ids, AthenaPerformance::PUT_ON_SALE)      
      @performance.tickets.each { |ticket| ticket.on_sale.should eq(@ticket_ids.include? ticket.id) }
    end

    it "should take tickets off sale" do
      #let's flip all the tickets to on_sale=true
      @performance.tickets.each { |ticket| ticket.on_sale = true }
      
      #we need to make sure we return the tickets with the right on_sale bit
      @ticket_ids.each do |id|
        @tickets_hash[id].on_sale = false
      end
      
      @ticket_ids.each do |id|
        FakeWeb.register_uri(:put, "http://localhost/tix/tickets/#{id}.json", :status => 200, :body => @tickets_hash[id].to_json)
      end

      @performance.bulk_edit_tickets(@ticket_ids, AthenaPerformance::TAKE_OFF_SALE)      
      @performance.tickets.each { |ticket| ticket.on_sale.should eq(!@ticket_ids.include?(ticket.id.to_i)) }
    end

    it "should delete tickets" do
      @ticket_ids.each do |id|
        FakeWeb.register_uri(:delete, "http://localhost/tix/tickets/#{id}.json", :status => 204)
      end
      @performance.bulk_edit_tickets(@ticket_ids, AthenaPerformance::DELETE)          
      @performance.tickets.size.should eq(@test_tickets.size - @num_tickets_to_test)
      @performance.tickets.each do |ticket|
        (@ticket_ids.include? ticket.id).should eq false
      end
    end

    it "should not take ticket off sale if it has already been sold" do
      #let's flip all the tickets to on_sale=true
      @performance.tickets.each { |ticket| ticket.on_sale = true }
      
      sold_ticket_id = @ticket_ids[0]      

      #sell one of the tickets
      @performance.tickets.each do |ticket|
        if ticket.id==sold_ticket_id.to_s
          ticket.sold = true
        end
      end

      @ticket_ids.each_with_index do |id, i|
        if id != sold_ticket_id
          FakeWeb.register_uri(:put, "http://localhost/tix/tickets/#{id}.json", :status => 200, :body => @tickets_hash[id].to_json)
        end
      end

      rejected_ids = @performance.bulk_edit_tickets(@ticket_ids, AthenaPerformance::TAKE_OFF_SALE)  
      rejected_ids.size.should eq 1
      rejected_ids[0].should eq sold_ticket_id
      @ticket_ids.delete_at(0)
      @performance.tickets.each { |ticket| ticket.on_sale.should eq(!@ticket_ids.include?(ticket.id.to_i)) }
    end

    it "should not take delete ticket if it has already been sold" do
      #let's flip all the tickets to on_sale=true
      @performance.tickets.each { |ticket| ticket.on_sale = true }

      sold_ticket_id = @ticket_ids[0]      

      #sell one of the tickets
      @performance.tickets.each do |ticket|
        if ticket.id==sold_ticket_id.to_s
          ticket.sold = true
        end
      end

      @ticket_ids.each_with_index do |id, i|
        if id != sold_ticket_id
          FakeWeb.register_uri(:delete, "http://localhost/tix/tickets/#{id}.json", :status => 204)
        end
      end

      rejected_ids = @performance.bulk_edit_tickets(@ticket_ids, AthenaPerformance::DELETE)  
      rejected_ids.size.should eq 1
      rejected_ids[0].should eq sold_ticket_id
      @ticket_ids.delete_at(0)
      @performance.tickets.each do |ticket|
        (@ticket_ids.include? ticket.id).should eq false
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
