require 'spec_helper'

describe DoorList do
  let(:show) { Factory(:show) }
  let(:buyer) { Factory(:person) }
  subject { DoorList.new(show) }

  before(:each) do
    show.stub(:tickets).and_return(5.times.collect { Factory(:ticket, :state => :sold)})
    show.tickets.each do |ticket|
      ticket.stub(:buyer).and_return(buyer)
    end
  end

  it "should save a reference to the show for which it was created" do
    subject.show.should eq show
  end

  it "should return an array of Buyers and their tickets" do
    list = subject.items
    list.each do |item|
      item.buyer.should eq buyer
      show.tickets.should include item.ticket
    end
  end
end
