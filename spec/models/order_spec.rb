require 'spec_helper'

describe Order do
  disconnect_sunspot
  subject { Factory(:order) }

  describe "payment" do
    it "returns a new Payment based on the transaction ID" do
      subject.payment.should be_an AthenaPayment
      subject.payment.transaction_id.should eq subject.transaction_id
    end
  end

  describe "#ticket_summary" do
    let(:organization)  { Factory(:organization) }
    let(:show1)         { Factory(:show, :organization => organization) }
    let(:show2)         { Factory(:show, :organization => organization) }
    let(:tickets1) { 3.times.collect { Factory(:ticket, :show => show1) } }
    let(:tickets2) { 3.times.collect { Factory(:ticket, :show => show2) } }
    let(:donations) { 2.times.collect { Factory(:donation, :organization => organization) } }

    subject do
      Order.new.tap do |order|
        order.for_organization(organization)
        order << tickets1
        order << tickets2
        order << donations
      end
    end   
    
    it "assigns the organization to the order" do
      subject.organization.should eq organization
    end 
    
    it "assembles a ticket summary" do
      subject.ticket_summary.should_not be_nil
      subject.ticket_summary.rows.each do |row|
        puts "#{row.quantity} #{row.ticket.section} #{row.show.id} #{row.show.id} #{row.show.event.name}"
      end
    end
  end

  # describe "#save" do
  #   subject { Factory.build(:order, :created_at => Time.now) }
  #   it "creates a purchase action after save" do
  #     subject.should_receive(:create_purchase_action)
  #     subject.save
  #   end
  # 
  #   it "generates a valid donation action for each donation" do
  #     donations = 2.times.collect { Factory(:donation) }
  #     subject << donations
  #     actions = subject.send(:create_donation_actions)
  #     actions.should have(2).donation_actions
  #     actions.each do |action|
  #       action.should be_valid
  #       donations.should include action.subject
  #     end
  #   end
  # end
  # 
  # describe "generating orders" do
  #   let(:organization) { Factory(:organization) }
  #   let(:tickets) { 3.times.collect { Factory(:ticket) } }
  #   let(:donations) { 2.times.collect { Factory(:donation, :organization => organization) } }
  # 
  #   subject do
  #     Order.new.tap do |order|
  #       order.for_organization(organization)
  #       order << tickets
  #       order << donations
  #     end
  #   end
  # 
  #   it "assigns the organization to the order" do
  #     subject.organization.should eq organization
  #   end
  # 
  #   it "creates an item that references each ticket" do
  #     subject.items.select(&:ticket?).size.should eq tickets.size
  #     subject.items.select(&:ticket?).each do |item|
  #       tickets.collect(&:id).should include item.product_id
  #     end
  #   end
  # 
  #   it "creates an item that references each donation" do
  #     subject.items.select(&:donation?).size.should eq donations.size
  #     subject.items.select(&:donation?).each do |item|
  #       donations.collect(&:id).should include item.product_id
  #     end
  #   end
  # end
end