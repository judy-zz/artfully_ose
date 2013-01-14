require 'spec_helper'

describe Exchange do
  disconnect_sunspot
  let(:items)       { 3.times.collect { FactoryGirl.build(:item) }}
  let(:order)       { FactoryGirl.build(:order, :items => items, :service_fee => 600) }
  let(:event)       { FactoryGirl.build(:event, :organization => order.organization) }
  let(:tickets)     { 3.times.collect { FactoryGirl.create(:ticket, :state => :on_sale, :organization => order.organization) } }

  subject { Exchange.new(order, items, tickets) }

  it { should be_valid }

  it "should initialize with an order and items" do
    subject.order.should be order
    subject.items.should be items
  end

  describe "#valid?" do
    it "should not be valid without items" do
      subject.items = []
      subject.should_not be_valid
    end

    it "should not be valid without any tickets" do
      subject.tickets = []
      subject.should_not be_valid
    end

    it "should not be valid if the number of tickets does not match the number of items" do
      subject.items.stub(:length).and_return(2)
      subject.tickets.stub(:length).and_return(3)
      subject.should_not be_valid
    end

    it "should not be valid if any of the items are not returnable" do
      subject.items.first.stub(:exchangeable?).and_return(false)
      subject.should_not be_valid
    end

    it "should not be valid if any of the tickets are comitted" do
      subject.tickets.first.stub(:committed?).and_return(true)
      subject.should_not be_valid
    end

    it "should not be valid if any of the tickets belong to another organization" do
      subject.tickets.first.organization = FactoryGirl.build(:organization)
      subject.should_not be_valid
    end
  end

  describe "service fees" do
    it "should calculate the service fee" do
      order.service_fee = 600
      subject.service_fee.should eq 600
    end

    it "should transfer the relevant service fees" do
      order.service_fee = 600
      subject.tickets.each { |ticket| ticket.stub(:exchange_to).and_return(true) }
      subject.submit
      exchange_order = subject.order.children.first
      exchange_order.service_fee.should eq 600
      order.reload.service_fee.should eq 0
    end

    it "should transfer the relevant service fees for the correct number of items" do
      order.service_fee = 600
      items = Array.wrap(FactoryGirl.build(:item))
      tickets = Array.wrap(FactoryGirl.create(:ticket, :state => :on_sale, :organization => order.organization))

      subject = Exchange.new(order, items, tickets)

      subject.tickets.each { |ticket| ticket.stub(:exchange_to).and_return(true) }
      subject.submit
      exchange_order = subject.order.children.first
      exchange_order.service_fee.should eq 200
      order.reload.service_fee.should eq 400
    end

    it "should account for free items" do
      free_ticket = FactoryGirl.create(:free_ticket, :state => :on_sale, :organization => order.organization)
      free_item = Item.for(free_ticket)
      order.items << free_item
      items = Array.wrap(FactoryGirl.build(:item))
      items << free_item
      tickets = Array.wrap(FactoryGirl.create(:ticket, :state => :on_sale, :organization => order.organization))
      tickets << free_ticket

      subject = Exchange.new(order, items, tickets)

      subject.tickets.each { |ticket| ticket.stub(:exchange_to).and_return(true) }
      subject.submit
      exchange_order = subject.order.children.first
      exchange_order.service_fee.should eq 200
      order.reload.service_fee.should eq 400      
    end
  end

  describe ".submit" do
    describe "return_items" do      
      it "should mark the exchanged items net as zero" do
        subject.submit
        subject.items.each do |item| 
          item.original_price.should eq 0
          item.price.should eq 0
          item.realized_price.should eq 0
          item.net.should eq 0
          item.state.should eq "exchanged"
          item.product.state.should eq "on_sale"
        end
      end
    end

    describe "sell_new_items" do
      it "should sell each new ticket to the person associated with the order" do
        subject.tickets.each { |ticket| ticket.should_receive(:exchange_to) }
        subject.submit
      end

      it "should post a metric for the exchange" do
        subject.tickets.should_not be_empty
        subject.tickets.each do |ticket|
          RestfulMetrics::Client.should_receive(:add_metric).with(ENV["RESTFUL_METRICS_APP"], "ticket_exchanged", 1)
        end
        subject.submit
      end

      it "should create an exchange order if all of the tickets are sold successfully" do
        subject.tickets.each { |ticket| ticket.stub(:exchange_to).and_return(true) }
        subject.should_receive(:create_order)
        subject.submit
      end
      
      it "should mark the exchangees items price/realized/net as equal to the previous items" do
        subject.tickets.each { |ticket| ticket.stub(:exchange_to).and_return(true) }
        subject.tickets.each { |ticket| ticket.stub(:sold_price).and_return(ticket.price) }
        subject.submit
        exchange_order = subject.order.children.first
        
        fake_item = Item.new
        fake_item.product= tickets.first
        
        exchange_order.items.each do |item|
          item.original_price.should  eq fake_item.original_price
          item.price.should           eq fake_item.price
          item.realized_price.should  eq fake_item.realized_price
          item.net.should             eq fake_item.net
          item.state.should           eq fake_item.state
        end
      end
    end

    describe "exchanging cash sales" do
      it "should sell each new ticket to the person associated with the order" do
        subject.tickets.each { |ticket| ticket.should_receive(:exchange_to) }
        subject.submit
      end
      
      it "should mark the exchangees items price/realized/net/state as equal to the previous items" do
        subject.tickets.each { |ticket| ticket.stub(:exchange_to).and_return(true) }
        subject.tickets.each { |ticket| ticket.stub(:sold_price).and_return(ticket.price) }
        original_state = items.first.state
        subject.submit
        exchange_order = subject.order.children.first
        
        fake_item = Item.new
        fake_item.product= tickets.first
                
        exchange_order.items.each do |item|
          item.original_price.should  eq fake_item.original_price
          item.price.should           eq fake_item.price
          item.realized_price.should  eq fake_item.realized_price
          item.net.should             eq fake_item.net
          item.state.should           eq original_state
        end
      end
    end
  end
end
