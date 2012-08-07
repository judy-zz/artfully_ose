require 'spec_helper'

describe Order do
  disconnect_sunspot
  subject { FactoryGirl.build(:order) }

  describe "payment" do
    it "returns a new Payment based on the transaction ID" do
      subject.payment.should be_an AthenaPayment
      subject.payment.transaction_id.should eq subject.transaction_id
    end
  end
  
  describe "total" do
    it "should report the prices and non-gift amounts to all items" do
      order = FactoryGirl.build(:order)
      order << FactoryGirl.build(:sponsored_donation)
      order.items.first.nongift_amount = 400
      order.total.should eq 1400
    end
  end

  describe "#ticket_summary" do
    let(:organization)  { FactoryGirl.build(:organization) }
    let(:show0)         { FactoryGirl.build(:show, :organization => organization) }
    let(:show1)         { FactoryGirl.build(:show, :organization => organization) }
    let(:tickets0) { 3.times.collect { FactoryGirl.build(:ticket, :show => show0) } }
    let(:tickets1) { 2.times.collect { FactoryGirl.build(:ticket, :show => show1) } }
    let(:donations) { 2.times.collect { FactoryGirl.build(:donation, :organization => organization) } }

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
      actions = subject.send(:create_donation_actions)
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