require 'spec_helper'

describe AthenaOrder do
  subject { Factory(:athena_order_with_id) }

  describe "schema" do
    %w( person_id organization_id customer_id transaction_id ).each do |attr|
      it { should respond_to attr }
    end
  end

  %w( person organization customer ).each do |association|
    it { should respond_to association }
    it { should respond_to association + "=" }
  end

  describe "#organization" do
    it "returns the organization" do
      subject.organization.should be_an Organization
      subject.organization.id.should eq subject.organization_id
    end

    it "stores the organization id when the organization is set" do
      organization = Factory(:organization)
      subject.organization = organization
      subject.organization.should eq organization
    end
  end

  describe "payment" do
    it "returns a new Payment based on the transaction ID" do
      subject.payment.should be_an AthenaPayment
      subject.payment.transaction_id.should eq subject.transaction_id
    end
  end

  describe "#person" do
    it "fetches the People record" do
      person =  Factory(:athena_person_with_id)
      subject.person = person
      subject.person.should eq person
    end

    it "does not make a request if the customer_id is not set" do
      subject.person = subject.person_id = nil
      subject.person.should be_nil
    end

    it "updates the customer id when assigning a new customer record" do
      subject.person = Factory(:athena_person_with_id, :id => 2)
      subject.person_id.should eq(2)
    end
  end

  describe "#customer" do
    it "fetches the Customer record" do
      customer =  Factory(:customer_with_id)
      subject.customer = customer
      subject.customer.should eq customer
    end

    it "does not make a request if the customer_id is not set" do
      subject.customer = subject.customer_id = nil
      subject.customer.should be_nil
    end

    it "updates the customer id when assigning a new customer record" do
      subject.customer = Factory(:customer_with_id, :id => 2)
      subject.customer_id.should eq(2)
    end
  end

  describe "parent" do
    it "fetches the Parent Order record" do
      parent = Factory(:athena_order_with_id)
      subject.parent = parent
      subject.parent.should eq parent
    end

    it "does not make a request if the parent_id is not set" do
      subject.parent = subject.parent_id = nil
      subject.parent.should be_nil
    end

    it "updates the parent id when assigning a new parent record" do
      subject.parent = Factory(:athena_order_with_id, :id => 2)
      subject.parent_id.should eq(2)
    end
  end

  describe "#items" do
    it "requests items for itself" do
      items = 2.times.collect { Factory(:athena_item) }
      subject.stub(:items).and_return(items)
      subject.items.should eq items
    end
  end

  describe "#save" do
    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/athena/actions.json", :body => Factory(:athena_purchase_action).encode)
      FakeWeb.register_uri(:get, "http://localhost/athena/items.json?orderId=1", :body=>"")
    end

    it "saves the items after saving the order" do
      FakeWeb.register_uri(:post, "http://localhost/athena/items.json", :body=>"")
      items = 2.times.collect { Factory(:athena_item) }
      subject.stub(:items).and_return(items)
      subject.save
    end

    it "creates a purchase action after save" do
      subject.should_receive(:create_purchase_action)
      subject.save
    end

    it "generates a valid donation action for each donation" do
      donations = 2.times.collect { Factory(:donation) }
      subject << donations
      actions = subject.send(:create_donation_actions)
      actions.should have(2).donation_actions
      actions.each do |action|
        action.should be_valid
        donations.should include action.subject
      end
    end
  end

  describe "generating athena orders" do
    let(:organization) { Factory(:organization) }
    let(:tickets) { 3.times.collect { Factory(:ticket_with_id) } }
    let(:donations) { 2.times.collect { Factory(:donation, :organization => organization) } }

    subject do
      AthenaOrder.new.tap do |order|
        order.for_organization organization
        order << tickets
        order << donations
      end
    end

    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/athena/orders.json", :body => subject.encode)
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

  describe ".in_range" do
    it "composes a GET request for a given set of Time objects" do
      start = Time.now.beginning_of_day
      stop = start.end_of_day
      FakeWeb.register_uri(:get, "http://localhost/athena/orders.json?timestamp=gt#{start.xmlschema.gsub(/\+/,'%2B')}&timestamp=lt#{stop.xmlschema.gsub(/\+/,'%2B')}", :body => "[]")
      AthenaOrder.in_range(start, stop)
      FakeWeb.last_request.path.should eq "/athena/orders.json?timestamp=gt#{start.xmlschema.gsub(/\+/,'%2B')}&timestamp=lt#{stop.xmlschema.gsub(/\+/,'%2B')}"
    end
  end
end
