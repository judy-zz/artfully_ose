require 'spec_helper'

describe Organization do
  subject { FactoryGirl.build(:organization) }

  it { should respond_to :name }
  it { should respond_to :users }
  it { should respond_to :memberships }

  describe "ability" do
    it { should respond_to :ability }
  end

  describe ".owner" do
    it "should return the first user as the owner of the organization" do
      user = FactoryGirl.build(:user)
      subject.users << user
      subject.owner.should eq user
    end
  end

  describe "#has_tax_info" do
    it "returns true if both ein and legal organization name are not blank" do
      subject.update_attributes({:ein => "111-4444", :legal_organization_name => "Some Org Name"})
      subject.should have_tax_info
    end

    it "returns false if both ein and legal organization name are blank" do
      subject.update_attributes({:ein => nil, :legal_organization_name => nil})
      subject.should_not have_tax_info
    end

    it "returns true if either ein or legal organization name are blank" do
      subject.update_attributes({:ein => "111-4444", :legal_organization_name => nil})
      subject.should_not have_tax_info

      subject.update_attributes({:ein => nil, :legal_organization_name => "Some Org Name"})
      subject.should_not have_tax_info
    end
  end

  describe "kits" do
    it "does not add a kit of the same type if one already exists" do
      kit = TicketingKit.new(:state => :activated)
      subject.kits << kit
      lambda { subject.kits << kit }.should raise_error Kit::DuplicateError
      subject.kits.should have(1).kit
    end

    it "does not raise an error if a different type of kit exists" do
      subject.kits << TicketingKit.new(:state => :activated)
      lambda { subject.kits << RegularDonationKit.new(:state => :activated) }.should_not raise_error Kit::DuplicateError
      subject.kits.should have(2).kits
    end

    it "should attempt to activate the kit before saving" do
      kit = FactoryGirl.build(:ticketing_kit)
      kit.should_receive(:activate!)
      subject.kits << kit
    end

    it "should not attempt to activate the kit if is new before saving" do
      kit = FactoryGirl.build(:ticketing_kit, :state => :activated)
      kit.should_not_receive(:activate!)
      subject.kits << kit
    end
  end

  describe "#authorization_hash" do
    context "with a Regular Donation Kit" do
      before(:each) do
        subject.kits << FactoryGirl.build(:regular_donation_kit, :state => :activated, :organization => subject)
      end

      it "sets authorized to true" do
        subject.authorization_hash[:authorized].should be_true
      end

      it "sets type to regular when it is not a fiscally sponsored project" do
        subject.authorization_hash[:type].should eq :regular
      end
    end

    context "with a Sponsored Donation Kit" do
      before(:each) do
        subject.kits << FactoryGirl.build(:sponsored_donation_kit, :state => :activated, :organization => subject)
      end

      it "sets authorized to true" do
        subject.authorization_hash[:authorized].should be_true
      end

      it "sets type to regular when it is not a fiscally sponsored project" do
        subject.authorization_hash[:type].should eq :sponsored
      end
    end

    context "when both kits have been created" do
      it "returns type of regular when the sponsored kit is cancelled" do
        subject.kits << FactoryGirl.build(:sponsored_donation_kit, :state => :pending, :organization => subject)
        subject.kits.where(:type => "SponsoredDonationKit").first.cancel_with_authority!
        subject.kits << FactoryGirl.build(:regular_donation_kit, :state => :activated, :organization => subject)
        subject.authorization_hash[:authorized].should be_true
        subject.authorization_hash[:type].should eq :regular
      end

      it "returns type of regular when the sponsored kit is pending" do
        subject.kits << FactoryGirl.build(:sponsored_donation_kit, :state => :pending, :organization => subject)
        subject.kits << FactoryGirl.build(:regular_donation_kit, :state => :activated, :organization => subject)
        subject.authorization_hash[:authorized].should be_true
        subject.authorization_hash[:type].should eq :regular
      end
    end

    context "without a Donation Kit" do
      it "sets authorized to false" do
        subject.authorization_hash[:authorized].should be_false
      end

      it "sets authorized to false if neither kit is active" do
        subject.kits << FactoryGirl.build(:sponsored_donation_kit, :state => :pending, :organization => subject)
        subject.kits << FactoryGirl.build(:regular_donation_kit, :state => :pending, :organization => subject)
        subject.authorization_hash[:authorized].should be_false
      end
    end
  end

  describe "#update_kits" do
    let(:kit) { mock(:sponsored_kit, :activated? => true, :cancelled? => true) }

    it "cancels the kit if the FSP is no longer active" do
      subject.stub(:fsp).and_return(mock(:fsp, :active? => false, :inactive? => true))
      subject.stub(:sponsored_kit).and_return(kit)

      kit.should_receive(:cancel_with_authority!)
      subject.send(:update_kits)
    end

    it "activates the kit if the FSP is active" do
      subject.stub(:fsp).and_return(mock(:fsp, :active? => true, :inactive? => false))
      subject.stub(:sponsored_kit).and_return(kit)

      kit.should_receive(:activate_without_prejudice!)
      subject.send(:update_kits)
    end
  end

  describe "#events_with_sales" do
    let(:org2) { FactoryGirl.build(:organization_with_reselling) }
    subject { FactoryGirl.build(:organization_with_reselling) }

    before do
      # An event produced and sold by this organization.
      create_event_with_a_sale subject

      # An event produced by this organization and sold by a reseller.
      create_event_with_a_sale subject, org2

      # An event produced by another organization and sold by this organization.
      create_event_with_a_sale org2, subject

      # An event produced and sold by another organization.
      create_event_with_a_sale org2
    end

    it "should have its own events with sales and events it has resold" do
      subject.should have(3).events_with_sales
    end

    def create_event_with_a_sale(producer, reseller = nil)
      FakeWeb.register_uri :post, "http://localhost:8982/solr/update?wt=ruby", :body => ""

      person = FactoryGirl.build(:person)

      order =
        if reseller
          FactoryGirl.build(:reseller_order, :organization => reseller, :person => person)
        else
          FactoryGirl.build(:order, :organization => producer, :person => person)
        end

      event = FactoryGirl.build(:event, :organization => producer)
      show = FactoryGirl.build(:show, :event => event, :organization => producer)
      ticket = FactoryGirl.build(:ticket, :show => show, :organization => producer, :state => :sold)

      item =
        if reseller
          FactoryGirl.build(:item, :product => ticket, :order => nil, :reseller_order => order, :show => show)
        else
          FactoryGirl.build(:item, :product => ticket, :order => order, :reseller_order => nil, :show => show)
        end

      order.items << item
      order.save!

      order.reload
      producer.reload
      reseller.reload if reseller

      producer.should_not == reseller
      order.should have(1).items
      event.should have(1).shows

      if reseller
        order.organization.should_not == item.show.organization
        order.items.first.show.should == show
        order.should have(1).external_order
        order.external_orders.first.organization.should == producer
      end
    end
  end
end
