require 'spec_helper'

describe Contribution do
  let(:organization){ Factory(:organization) }
  let(:person) { Factory(:person) }
  let(:attributes) do
    {
      :subtype         => "Donation (Cash)",
      :amount          => 2500,
      :occurred_at     => "2011-08-17 02:28 pm",
      :details         => "Some details.",
      :organization_id => organization.id,
      :contributor_id  => person.id
    }
  end

  subject { Contribution.new(attributes)}

  [:contributor_id, :subtype, :amount, :details, :organization_id].each do |attribute|
    it "loads the #{attribute} when created" do
      subject.send(attribute).should eq attributes[attribute]
    end
  end

  it "parses occurred_at when it is loaded" do
    subject.occurred_at.should eq Time.zone.parse(attributes[:occurred_at])
  end

  it "fetches the person record for the given contributor id" do
    subject.contributor.should eq person
  end

  describe "#has_contributor?" do
    it "has a contributor when one is found" do
      subject.stub(:contributor).and_return(person)
      subject.should have_contributor
    end

    it "does not have a contributor when one is not found" do
      subject.stub(:contributor).and_return(nil)
      subject.should_not have_contributor
    end
  end

  describe "#build_order" do
    let(:order) { subject.send(:build_order) }

    it "sets the person and organization" do
      order.person_id.should eq subject.contributor_id
      order.organization_id.should eq subject.organization_id
    end

    it "should specify that the order skip creation of actions" do
      order.skip_actions.should be_true
    end
  end

  describe "build_item" do
    let(:order) { Factory(:athena_order_with_id) }
    let(:item) { subject.send(:build_item, order, 100 )}

    it "sets the order id for the item to the given order" do
      item.order_id.should eq order.id
    end

    it "sets the product type to Donation" do
      item.product_type.should eq "Donation"
    end

    it "sets the state to settled" do
      item.state.should eq "settled"
      item.should be_settled
    end

    it "should set price, realized_price, and net to the given price" do
      item.price.should eq 100
      item.realized_price.should eq 100
      item.net.should eq 100
    end
  end

  describe "#build_action" do
    let(:action) { subject.send(:build_action)}

    it "maps attributes onto the Action" do
      action.action_subtype.should eq subject.subtype
      action.organization_id.should eq subject.organization_id
      action.occurred_at.should eq subject.occurred_at
      action.details.should eq subject.details
      action.person_id.should eq subject.contributor_id
    end
  end

  describe "#save" do
    let(:order) { mock(:order, :save! => true) }
    let(:item) { mock(:item, :save! => true) }
    let(:action) { mock(:action, :save! => true) }

    before(:each) do
      subject.stub(:build_order).and_return(order)
      subject.stub(:build_item).and_return(item)
      subject.stub(:build_action).and_return(action)
    end

    it "saves the models it built" do
      order.should_receive(:save!).once
      item.should_receive(:save!).once
      action.should_receive(:save!).once

      subject.save
    end
  end
end
