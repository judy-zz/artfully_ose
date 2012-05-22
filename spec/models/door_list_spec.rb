require 'spec_helper'

describe DoorList do
  disconnect_sunspot  
  let(:show)                  { Factory(:show_with_tickets) }
  let(:buyer)                 { Factory(:person) }
  let(:buyer_without_email)   { Factory(:person_without_email) }
  let(:special_instructions)  { "Seriously, that's like Eggs 101, Woodhouse." }

  describe "items" do
    
    before(:each) do
      items = []      
      show.tickets[0..5].each do |t|
        t.stub(:special_instructions).and_return(special_instructions)
      end   
      show.tickets[0..2].each { |t| t.sell_to buyer }
      show.tickets[3..4].each { |t| t.sell_to buyer_without_email }
      @door_list = DoorList.new(show)
    end
    
    describe "buyers without emails" do  
      it "should work for buyers who have no email address" do
        @door_list.should have(5).items
      end
    end
  
    describe "buyers with emails" do
      it "should save a reference to the show for which it was created" do
        @door_list.show.should eq show
      end
  
      it "should return an array of Buyers and their tickets" do
        list = @door_list.items
        list.each do |item|
          item.buyer.should eq item.ticket.buyer
          show.tickets.should include item.ticket
        end
      end
    end
  end
end
