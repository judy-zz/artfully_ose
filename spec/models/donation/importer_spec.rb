require 'spec_helper'

describe Donation::Importer do
  subject { Donation::Importer }
  let(:organization) { Factory(:connected_organization) }

  describe "importing donations" do
    it "should fetch donations since the last refresh" do
      FA::Donation.should_receive(:find_by_member_id).with(organization.fa_member_id, organization.fiscally_sponsored_project.updated_at - 1.day).and_return([])
      subject.for_organization(organization)
    end
  end

  describe "processing donations" do
    let(:donations) { Array.wrap(Factory(:fa_donation))}

    it "creates an order for each donation" do
      subject.should_receive(:create_order).exactly(donations.count).times
      subject.process(donations, organization)
    end

    it "creates a person record for the number each unique donor" do
      subject.stub(:create_order)
      unique_count = donations.collect{ |d| [d.donor.email, d.donor.first_name, d.donor.last_name].join}.uniq.size
      subject.should_receive(:create_person).exactly(unique_count).times
      subject.process(donations, organization)
    end
  end

  describe ".create_person" do
    let(:donor) { Factory(:fa_donor) }

    it "uses the anonymous record for an organization if the donor has no information" do
      person = subject.send(:create_person, mock(:donor, :has_information? => false), organization)
      person.should be_dummy
    end

    it "finds uses an existing person record if one can be found" do
      person = organization.people.create(:email => donor.email, :first_name => donor.first_name, :last_name => donor.last_name)
      new_person = subject.send(:create_person, donor, organization)
      new_person.should eq person
    end

    it "creates a new person record if one does not yet exist" do
      Person.delete_all(:email => donor.email, :first_name => donor.first_name, :last_name => donor.last_name)
      organization.people.should_receive(:create)
      subject.send(:create_person, donor, organization)
    end
  end

  describe ".create_order" do
    let(:donation) { Factory(:fa_donation)}
    let(:donor) { Factory(:person) }

    it "creates a new order if one does not exist for the given fa_id" do
      Order.delete_all(:fa_id => donation.id)
      order = subject.send(:create_order, donation, organization, donor)
      order.fa_id.should eq donation.id
    end

    it "uses an existing order if one exists" do
      order = Factory(:order, :organization => organization, :fa_id => donation.id)
      new_order = subject.send(:create_order, donation, organization, donor)
      new_order.should eq order
    end
  end

  describe "create_or_update_items" do
    let(:order) { Factory(:order) }
    let(:donation) { Factory(:fa_donation)}

    it "creates a new item for the donation if it is a new order" do
      subject.send(:create_or_update_items, order, donation, organization)
      order.items.should_not be_empty
    end

    it "updates the deatils if the item already exists" do
      order.items.stub(:blank?).and_return(false)
      order.items.stub(:first).and_return(mock(:item))
      order.items.first.should_receive(:update_attributes)
      subject.send(:create_or_update_items, order, donation, organization)
    end
  end

  describe ".item_attributes" do
    let(:order) { Factory(:order) }
    let(:donation) { Factory(:fa_donation)}
    let(:item) { subject.send(:item_attributes, donation, organization, order) }

    it "creates a hash of attributes for new item creation" do
      item[:price].should eq donation.amount.to_f * 100
      item[:realized_price].should eq donation.amount.to_f * 100
      item[:net].should eq ((donation.amount.to_f * 100) * 0.94)
      item[:fs_project_id].should eq donation.fs_project_id
      item[:nongift_amount].should eq donation.nongift.to_f * 100
      item[:is_noncash].should eq donation.is_noncash
      item[:is_stock].should be_false
      item[:reversed_at].should eq Time.at(donation.reversed_at)
      item[:reversed_note].should eq donation.reversed_note
      item[:fs_available_on].should eq donation.fs_available_on
      item[:is_anonymous].should eq donation.is_anonymous
    end
  end
end