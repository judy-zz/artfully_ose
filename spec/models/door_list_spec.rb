require 'spec_helper'

describe DoorList do
  let(:performance) { Factory(:athena_performance_with_id) }
  let(:buyer) { Factory(:athena_person_with_id) }
  subject { DoorList.new(performance) }

  before(:each) do
    performance.stub(:tickets).and_return(5.times.collect { Factory(:ticket_with_id, :sold => true)})
    performance.tickets.each do |ticket|
      ticket.stub(:buyer).and_return(buyer)
    end
  end

  it "should save a reference to the performance for which it was created" do
    subject.performance.should eq performance
  end

  it "should return an array of Buyers and their tickets" do
    list = subject.items
    list.each do |item|
      item.buyer.should eq buyer
      performance.tickets.should include item.ticket
    end
  end
end
