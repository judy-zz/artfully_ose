require 'spec_helper'

describe Ticket do
  disconnect_sunspot
  subject { Factory(:ticket) }

  describe "attributes" do
    it { should respond_to :venue }
    it { should respond_to :price }
    it { should respond_to :sold_at }
    it { should respond_to :sold_price }
    it { should respond_to :items }
  end

  describe "available tickets" do
    let(:conditions) { Factory.attributes_for(:ticket, :state => :on_sale) }
  
    before(:each) do
      10.times.collect { Factory(:ticket, conditions) }
    end
  
    it "adds a limit of 4 tickets if no limit is specified" do
      Ticket.available(conditions).should have(4).tickets
    end
  
    it "uses the limit when specified" do
      Ticket.available(conditions, 6).should have(6).tickets
    end
  
    it "defaults to searching for tickets marked as on sale" do
      ticket = Ticket.find(:first, :conditions => conditions)
      ticket.update_attribute(:state, :off_sale)
      Ticket.available().should_not include(ticket)
    end
  end
  
  describe "items and sold_item and special_instructions" do
    it "should return the list of items that it is associated with" do
      ticket = Factory(:ticket)
      
      items = [
        Factory(:item, :product=>ticket),      
        Factory(:exchanged_item, :product=>ticket),
        Factory(:refunded_item, :product=>ticket)
        ]

      ticket.items.should eq items
    end
    
    it "should return the item associated with its most recent sale" do
      ticket = Factory(:ticket)
      items = [
        Factory(:item, :product=>ticket),      
        Factory(:exchanged_item, :product=>ticket),
        Factory(:refunded_item, :product=>ticket)
        ]
      
      ticket.sold_item.should eq items[0]
      ticket.sold_item.state.should eq "purchased"
    end
    
    it "should return the settled item" do
      ticket = Factory(:ticket)
      items = [     
        Factory(:exchanged_item, :product=>ticket),
        Factory(:refunded_item, :product=>ticket),
        Factory(:settled_item, :product=>ticket)
        ]
      
      ticket.sold_item.should eq items[2]
      ticket.sold_item.state.should eq "settled"
    end
    
    it "should return nil if there is no sold item" do
      ticket = Factory(:ticket)
      items = [  
        Factory(:exchanged_item, :product=>ticket),
        Factory(:refunded_item, :product=>ticket)
        ]
      ticket.sold_item.should be_nil   
    end
    
    it "should return the comp if there is no purchased item" do
      ticket = Factory(:ticket)
      items = [
        Factory(:comped_item, :product=>ticket),      
        Factory(:exchanged_item, :product=>ticket),
        Factory(:refunded_item, :product=>ticket)
        ]
      
      ticket.sold_item.should eq items[0]
      ticket.sold_item.state.should eq "comped"
    end
    
    it "should return the exchangee item if there is no comp" do
      ticket = Factory(:ticket)
      items = [
        Factory(:exchangee_item, :product=>ticket),      
        Factory(:exchanged_item, :product=>ticket),
        Factory(:refunded_item, :product=>ticket)
        ]
      
      ticket.sold_item.should eq items[0]
      ticket.sold_item.state.should eq "exchangee"
    end
    
    it "should return the special instructions from the sold item" do
      special_instructions = "I'm not saying I invented the turtleneck."
      ticket = Factory(:ticket)
      order = Factory(:order, :special_instructions => special_instructions)
      settled_item = Factory(:settled_item, :product=>ticket, :order => order)
      items = [
        Factory(:refunded_item, :product=>ticket),
        settled_item
        ]      
      ticket.special_instructions.should eq special_instructions
    end
    
    it "should return special_instructions of nil if there is no sold_item" do
      ticket = Factory(:ticket)
      refunded_item = Factory(:refunded_item, :product=>ticket)
      items = Array.wrap(refunded_item)   
      refunded_item.should_not_receive(:order)
      ticket.special_instructions.should be_nil      
    end
  end
  
  describe "#expired?" do
    it "is considered to be expired if the show time is in the past" do
      subject.show = Factory(:expired_show)
      subject.should be_expired
    end
  
    it "is not considered to be expired if the show time is in the future" do
      subject.show = Factory(:show)
      subject.should_not be_expired
    end
  end
  
  describe "#on_sale?" do
    subject { Factory(:ticket, :state => "on_sale") }
    it { should be_on_sale }
    it { should_not be_off_sale }
  end
  
  describe "#on_sale!" do
    it { should respond_to :on_sale! }
  
    it "marks the ticket as on sale" do
      subject.on_sale!
      subject.should be_on_sale
    end
  
    it "saves the updated ticket" do
      subject.stub!(:save!)
      subject.should_receive(:save!).and_return(true)
      subject.on_sale!
    end
  end
  
  describe "#off_sale?" do
    subject { Factory(:ticket, :state => :off_sale) }
    it { should be_off_sale }
    it { should_not be_on_sale }
  end
  
  describe "#off_sale!" do
    subject { Factory(:ticket, :state => :on_sale) }
  
    it { should respond_to :off_sale! }
  
    it "marks the ticket as on sale" do
      subject.off_sale!
      subject.should_not be_on_sale
    end
  
    it "saves the updated ticket" do
      subject.stub!(:save!)
      subject.should_receive(:save!)
      subject.off_sale!
    end
  end
  
   describe "#take_off_sale" do
     it "does not be marked as off sale if it is already sold" do
       subject.state = "sold"
       subject.should_not_receive(:save!)
       subject.take_off_sale
       subject.should be_sold
     end
   
     it "returns false if it is already sold" do
       subject.state = "sold"
       subject.take_off_sale.should be_false
     end
   end
   
   describe "#sell_to" do
     let (:buyer) { Factory(:person) }
     subject { Factory(:ticket, :state => :on_sale) }
   
     it "defaults to current time if time is not provided" do
       subject.sell_to(buyer)
       subject.sold_at.should_not eq nil
     end
   
     it "sets sold_at to the time provided" do
       when_it_got_sold = Time.now + 1.hour
       subject.sell_to(buyer, when_it_got_sold)
       subject.sold_at.should eq when_it_got_sold
     end
   
     it "sets sold_price to price" do
       subject.sell_to(buyer)
       subject.sold_price.should eq subject.price
     end
   
     it "marks the ticket as sold" do
       subject.sell_to(buyer)
       subject.should be_sold
     end
   
     it "saves the updated ticket" do
       subject.should_receive(:save!)
       subject.sell_to(buyer)
     end
   
     it "sets the buyer after being sold" do
       subject.sell_to(buyer)
       subject.buyer.should eq buyer
     end
   end
   
   describe "#comp_to" do
     let (:buyer) { Factory(:person) }
     subject { Factory(:ticket, :state => :on_sale) }
   
     it "marks the ticket as comped" do
       subject.comp_to(buyer)
       subject.state.should == "comped"
     end
   
     it "defaults to current time if time is not provided" do
       subject.comp_to(buyer)
       subject.sold_at.should_not eq nil
     end
   
     it "sets the sold_price to 0" do
       subject.comp_to(buyer)
       subject.sold_price.should eq 0
     end
   
     it "sets sold_at to the time provided" do
       when_it_got_sold = Time.now + 1.hour
       subject.comp_to(buyer, when_it_got_sold)
       subject.sold_at.should eq when_it_got_sold
     end
   
     it "saves the updated ticket" do
       subject.should_receive(:save!)
       subject.comp_to(buyer)
     end
   
     it "sets the buyer after being sold" do
       subject.comp_to(buyer)
       subject.buyer.should eq buyer
     end
   end
   
   describe "#returnable?" do
     it "is returnable if it is not expired" do
       subject.stub(:expired?).and_return(false)
       subject.should be_returnable
     end
   
     it "is not returnable if it is expired" do
       subject.stub(:expired?).and_return(true)
       subject.should_not be_returnable
     end
   end
   
   describe "#exchangeable?" do
     it "is exchangeable if it is not expired and sold" do
       subject.stub(:expired?).and_return(false)
       subject.stub(:sold?).and_return(true)
       subject.should be_exchangeable
     end
   
     it "is not exchangeable if it is expired" do
       subject.stub(:expired?).and_return(true)
       subject.should_not be_exchangeable
     end
   
     it "is not exchangeable if it is comped" do
       subject.stub(:comped?).and_return(true)
       subject.should_not be_exchangeable
     end
   end
   
   describe "#refundable?" do
     it "is refundable if it is sold" do
       subject.stub(:sold?).and_return(true)
       subject.should be_refundable
     end
   
     it "is not refundable if it is comped" do
       subject.stub(:comped?).and_return(true)
       subject.should_not be_refundable
     end
   end
   
   describe "return!" do
     subject { Factory(:sold_ticket) }
   
     it "removes the buyer from the item" do
       subject.return!
       subject.buyer_id.should be_nil
     end
   
     it "removes the sold price and sold time" do
       subject.return!
       subject.sold_at.should be_nil
       subject.sold_price.should be_nil
     end
   
     it "puts the ticket back on sale" do
       subject.return!
       subject.should be_on_sale
     end
   end
   
   describe "#put_on_sale" do
     let(:tickets) { 5.times.collect { Factory(:ticket, :state => :off_sale) } }
   
     it "sends a request to patch the state of all tickets" do
       Ticket.put_on_sale(tickets)
     end
   
     it "does not issue the request if any of the tickets can not be put on sale" do
       tickets.first.state = :comped
       Ticket.should_not_receive(:patch)
       Ticket.put_on_sale(tickets)
     end
   
     it "updates the attributes for each ticket" do
       Ticket.put_on_sale(tickets)
       tickets.each do |ticket|
         ticket.should be_on_sale
       end
     end
   end
   
  describe "#take_off_sale" do
    let(:tickets) { 5.times.collect { Factory(:ticket, :state => :on_sale) } }
  
    it "takes tickets off sale" do
      Ticket.take_off_sale(tickets)
      tickets.each { |t| t.should be_off_sale }
    end
  
    it "does not issue the request if any of the tickets can not be put on sale" do
      tickets.first.state = :off_sale
      Ticket.take_off_sale(tickets)
    end
      
    it "updates the attributes for each ticket" do
      Ticket.take_off_sale(tickets)
      tickets.each do |ticket|
        ticket.should be_off_sale
      end
    end
  end
  
  describe "create_many" do
    let(:organization) { Factory(:organization) }
    let(:show) { Factory(:show, :event => Factory(:event), :organization => organization) }
    let(:section) { Factory(:section) }
    
    def check_tix(quantity, hash)
      created_tickets = Ticket.where(hash)
      created_tickets.length.should eq quantity
      created_tickets.each do |ticket|
        ticket.sold_at.should be_nil
        ticket.buyer.should be_nil
        ticket.sold_price.should be_nil
      end
    end
    
    it "should create a bunch of tickets" do
      section.price = rand(40000)
      quantity = 13
      tickets = Ticket.create_many(show, section, quantity)
      tickets.num_inserts.should eq quantity
      check_tix(quantity, :venue => show.event.venue.name, 
                           :show_id => show.id, 
                           :organization_id => show.organization.id, 
                           :price => section.price,
                           :section_id => section.id)
    end
    
    it "should default to section.capacity if there is no quantity" do
      section.price = rand(40000)
      tickets = Ticket.create_many(show, section)
      tickets.num_inserts.should eq section.capacity
      check_tix(section.capacity, :venue => show.event.venue.name, 
                                 :show_id => show.id, 
                                 :organization_id => show.organization.id, 
                                 :price => section.price,
                                 :section_id => section.id)
    end
  end
end