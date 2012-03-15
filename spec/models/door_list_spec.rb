require 'spec_helper'

describe DoorList do
  disconnect_sunspot
  let(:show) { Factory(:show) }
  let(:buyer) { Factory(:person) }
  let(:buyer_without_email) { Factory(:person_without_email) }
  subject { DoorList.new(show) }

  describe "buyers without emails" do

    before(:each) do
      subject.stub(:tickets).and_return(5.times.collect { Factory(:ticket, :state => :sold)})
      (0..2).each do |t|
        subject.tickets[t].stub(:buyer).and_return(buyer_without_email)
      end
      (3..5).each do |t|
        subject.tickets[t].stub(:buyer).and_return(buyer)
      end
    end

    it "should work for buyers who have no email address" do
      subject.should have(5).items
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

  describe "items" do
    let(:special_instructions) { "Seriously, that's like Eggs 101, Woodhouse." }
    let(:order) { Factory(:order, :person => buyer, :special_instructions => special_instructions) }
    
    before(:each) do
      tickets = 5.times.collect { Factory(:ticket, :state => :sold, :show => show, :buyer => buyer)}
      items = []
      tickets.each { |t| items << Factory(:item, :product => t, :order => order)}
    end
    
    describe "buyers without emails" do  
      before(:each) do
        (0..2).each do |t|
          show.tickets[t].stub(:buyer).and_return(buyer_without_email)
        end
        (3..4).each do |t|
          show.tickets[t].stub(:buyer).and_return(buyer)
        end
      end
    
      it "should work for buyers who have no email address" do
        subject.should have(5).items
      end
    end
  
    describe "buyers with emails" do
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
  
    describe "special instructions" do
      it "should be included when they are present on the order" do
        subject.items.each do |item|
          item.special_instructions.should eq special_instructions
        end  
      end
    end
  end
end
