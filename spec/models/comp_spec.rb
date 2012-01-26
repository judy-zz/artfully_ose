require 'spec_helper'

describe Comp do
  disconnect_sunspot
  let(:organization) { Factory(:organization) }
  let(:show) { Factory(:show) }
  let(:benefactor) { Factory(:user_in_organization) }
  let(:tickets) { 10.times.collect { Factory(:ticket, :show => show) } }
  let(:recipient) { Factory(:person) }

  describe "passing ticket ids instead of actual tickets" do
    before(:each) do 
      selected_tickets = [] 
      (0..2).each do |i|
        selected_tickets << tickets[i].id
      end
      Ticket.should_receive(:find).exactly(3).times.and_return(tickets[0], tickets[1], tickets[2])
      @comp = Comp.new(show, selected_tickets, recipient)
      @comp.reason = "comment"
      @comp.submit(benefactor)
    end
    
    it "creates an order with a total of zero" do
      created_order = Order.find(@comp.order.id)
      created_order.total.should eq 0
    end
    
    it "puts the comp comment on the order" do
      @comp.order.should_not be_nil
      @comp.order.details.should eq "Comped by: #{benefactor.email} Reason: comment"
    end
    
    it "marks the items as comped with a realized price a net of zero" do
      @comp.order.items.each do |item|
        item.realized_price.should eq 0
        item.price.should eq 0
        item.net.should eq 0
        item.state.should eq "comped"
      end
    end
    
    it "marks the tickets as comped and their sold price should be zero" do
      @comp.order.items.each do |item|
        item.product.sold_price.should eq 0
      end
    end        
  end

  describe "comping valid tickets to a person" do
    
    before(:each) do 
      selected_tickets = tickets[0..1]
      Ticket.should_not_receive(:find)
      @comp = Comp.new(show, selected_tickets, recipient)
      @comp.reason = "comment"
      @comp.submit(benefactor)
    end
    
    it "creates an order with a total of zero" do
      created_order = Order.find(@comp.order.id)
      created_order.total.should eq 0
    end
    
    it "puts the comp comment on the order" do
      @comp.order.should_not be_nil
      @comp.order.details.should eq "Comped by: #{benefactor.email} Reason: comment"
    end
    
    it "marks the items as comped with a realized price a net of zero" do
      @comp.order.items.each do |item|
        item.realized_price.should eq 0
        item.price.should eq 0
        item.net.should eq 0
        item.state.should eq "comped"
      end
    end
    
    it "marks the tickets as comped and their sold price should be zero" do
      @comp.order.items.each do |item|
        item.product.sold_price.should eq 0
      end
    end
  end
end