require 'spec_helper'

describe DoorList do
  disconnect_sunspot  
  let(:show) { Factory(:show) }
  let(:buyer) { Factory(:person) }
  let(:buyer_without_email) { Factory(:person_without_email) }
  subject { DoorList.new(show) }

  describe "buyers without emails" do
    
    before(:each) do
      show.stub(:tickets).and_return(5.times.collect { Factory(:ticket, :state => :sold)})
      (0..2).each do |t|
        show.tickets[t].stub(:buyer).and_return(buyer_without_email)
      end
      (3..5).each do |t|
        show.tickets[t].stub(:buyer).and_return(buyer)
      end
    end
    
    it "should work for buyers who have no email address" do
      list = subject.items   
    end
  end
  
  describe "buyers with emails" do
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
end
