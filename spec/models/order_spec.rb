require 'spec_helper'

describe Order do
  disconnect_sunspot
  subject { FactoryGirl.build(:order) }

  describe "payment" do
    it "returns a new Payment based on the transaction ID" do
      subject.payment.should be_a CreditCardPayment
      subject.payment.transaction_id.should eq subject.transaction_id
    end
  end

  describe "refundable_items" do
    it "should allow refunds on all items if the payment method is anything other than credit" do
      subject.items = 3.times.collect { FactoryGirl.create(:item) }
      subject.refundable_items.length.should eq 3
    end

    it "should allow refunds on all unsettled items if the payment method is credit" do
      credit_card_order = FactoryGirl.create(:credit_card_order)
      credit_card_order.items = 3.times.collect { FactoryGirl.create(:item) }
      credit_card_order.refundable_items.length.should eq 3

      settlement = FactoryGirl.create(:settlement)
      Item.settle(credit_card_order.items, settlement)
      credit_card_order.reload.refundable_items.length.should eq 0
    end

    it "should allow donations to be refunded unless we have settled" do
      order = FactoryGirl.build(:credit_card_order)
      order << FactoryGirl.create(:donation, :organization => order.organization)
      order.save
      order.refundable_items.length.should eq 1
      Item.settle(order.items, FactoryGirl.create(:settlement))
      order.reload.refundable_items.should be_empty
    end
  end

  describe "transaction_id" do
    it "should return the transaction_id" do
      subject.transaction_id = "12345"
      subject.transaction_id.should eq "12345"
    end

    it "should return the transaction_id of the parent if self.transaction_id is null" do
      parent = FactoryGirl.create(:order, :transaction_id => "abcdef")
      subject.parent = parent
      subject.transaction_id=nil
      subject.transaction_id.should eq parent.transaction_id
    end

    it "should return the transaction_id of the parent if self.transaction_id is null" do
      grandpa = FactoryGirl.create(:order, :transaction_id => "99999")
      parent = FactoryGirl.create(:order, :transaction_id => nil, :parent => grandpa)
      subject.parent = parent
      subject.transaction_id=nil
      subject.transaction_id.should eq "99999"
    end

    it "should return nil if transaction_id is null on self.parent" do
      parent = FactoryGirl.create(:order, :transaction_id => nil)
      subject.parent = parent
      subject.transaction_id=nil
      subject.transaction_id.should be_nil
    end
  end
  
  describe "total" do
    it "should report the prices and non-gift amounts to all items" do
      order = FactoryGirl.build(:order)
      order << FactoryGirl.build(:donation)
      order.items.first.nongift_amount = 400
      order.total.should eq 1400
    end
  end

  describe "#ticket_summary" do
    let(:organization)  { FactoryGirl.create(:organization) }
    let(:show0)         { FactoryGirl.create(:show, :organization => organization) }
    let(:show1)         { FactoryGirl.create(:show, :organization => organization) }
    let(:tickets0) { 3.times.collect { FactoryGirl.create(:ticket, :show => show0) } }
    let(:tickets1) { 2.times.collect { FactoryGirl.create(:ticket, :show => show1) } }
    let(:donations) { 2.times.collect { FactoryGirl.create(:donation, :organization => organization) } }

    subject do
      Order.new.tap do |order|
        order.for_organization(organization)
        order << tickets0
        order << tickets1
        order << donations
      end
    end   
    
    it "assigns the organization to the order" do
      subject.organization.should eq organization
    end 

    it "assembles a ticket summary" do
      subject.ticket_summary.should_not be_nil
      subject.ticket_summary.rows.length.should eq 2
      subject.ticket_summary.rows[0].show.should eq show0
      subject.ticket_summary.rows[0].tickets.length.should eq tickets0.length   
      subject.ticket_summary.rows[1].show.should eq show1
      subject.ticket_summary.rows[1].tickets.length.should eq tickets1.length      
    end
  end

  describe "#save" do
    subject { FactoryGirl.build(:order, :created_at => Time.now) }
    it "creates a purchase action after save" do
      subject.should_receive(:create_purchase_action)
      subject.save
    end
  
    it "generates a valid donation action for each donation" do
      donations = 2.times.collect { FactoryGirl.build(:donation) }
      subject << donations
      actions = subject.send(:create_donation_actions_without_delay)
      actions.should have(2).donation_actions
      actions.each do |action|
        action.should be_valid
        action.subject.should eq subject
      end
    end
  end
  
  describe "generating orders" do
    let(:organization) { FactoryGirl.build(:organization) }
    let(:tickets) { 3.times.collect { FactoryGirl.build(:ticket) } }
    let(:donations) { 2.times.collect { FactoryGirl.build(:donation, :organization => organization) } }
  
    subject do
      Order.new.tap do |order|
        order.for_organization(organization)
        order << tickets
        order << donations
      end
    end
  
    it "assigns the organization to the order" do
      subject.organization.should eq organization
    end
  
    it "creates an item that references each ticket" do
      subject.items.select(&:ticket?).size.should eq tickets.size
      subject.items.select(&:ticket?).each do |item|
        tickets.collect(&:id).should include item.product_id
      end
    end
  
    it "creates an item that references each donation" do
      subject.items.select(&:donation?).size.should eq donations.size
      subject.items.select(&:donation?).each do |item|
        donations.collect(&:id).should include item.product_id
      end
    end
  end
end