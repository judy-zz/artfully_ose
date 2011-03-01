require 'spec_helper'

describe AthenaOrder do
  subject { Factory(:athena_order) }

  describe "schema" do
    it { should respond_to :person_id }
    it { should respond_to :organization_id }
    it { should respond_to :customer_id }
  end

  %w( person organization customer ).each do |association|
    it { should respond_to association }
    it { should respond_to association + "=" }
  end

  describe "#organization" do
    it "should return the organization" do
      subject.organization.should be_an Organization
      subject.organization.id.should eq subject.organization_id
    end

    it "should store the organization id when the organization is set" do
      organization = Factory(:organization)
      subject.organization = organization
      subject.organization.should eq organization
    end
  end

  describe "#person" do
    it "should fetch the People record" do
      person =  Factory(:athena_person_with_id)
      subject.person = person
      subject.person.should eq person
    end

    it "should not make a request if the customer_id is not set" do
      subject.person = subject.person_id = nil
      subject.person.should be_nil
    end

    it "should update the customer id when assigning a new customer record" do
      subject.person = Factory(:athena_person_with_id, :id => 2)
      subject.person_id.should eq(2)
    end
  end

  describe "#customer" do
    it "should fetch the Customer record" do
      customer =  Factory(:customer_with_id)
      subject.customer = customer
      subject.customer.should eq customer
    end

    it "should not make a request if the customer_id is not set" do
      subject.customer = subject.customer_id = nil
      subject.customer.should be_nil
    end

    it "should update the customer id when assigning a new customer record" do
      subject.customer = Factory(:customer_with_id, :id => 2)
      subject.customer_id.should eq(2)
    end
  end

  describe "#items" do
    it "should request items for itself" do
      items = 2.times.collect { Factory(:athena_item) }
      subject.stub(:items).and_return(items)
      subject.items.should eq items
    end
  end

  describe "#save" do
    it "should save the items after saving the order" do
      items = 2.times.collect { Factory(:athena_item) }
      items.each { |item| item.should_receive(:save) }
      subject.stub(:items).and_return(items)
      subject.save
    end
  end

  describe "#generate" do
    let(:organization) { Factory(:organization) }
    let(:tickets) { 3.times.collect { Factory(:ticket_with_id) } }
    let(:donations) { 2.times.collect { Factory(:donation, :organization => organization) } }

    subject do
      AthenaOrder.generate do |order|
        order.for_organization organization
        order.for_items tickets
        order.for_items donations
      end
    end

    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/orders/orders/.json", :body => subject.encode)
    end

    it "should assign the organization to the order" do
      subject.organization.should eq organization
    end

    it "should create an item that references each ticket" do
      subject.items.select { |item| item.item_type == "AthenaTicket" }.size.should eq tickets.size
      subject.items.select { |item| item.item_type == "AthenaTicket" }.each do |item|
        tickets.collect(&:id).should include item.item_id
      end
    end

    it "should create an item that references each donation" do
      subject.items.select { |item| item.item_type == "Donation" }.size.should eq donations.size
      subject.items.select { |item| item.item_type == "Donation" }.each do |item|
        donations.collect(&:id).should include item.item_id
      end
    end

  end
end
