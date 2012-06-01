require 'spec_helper'

describe Donation::Importer do
  disconnect_sunspot
  subject { Donation::Importer }
  let(:organization) { Factory(:connected_organization) }

  describe "importing donations" do
    it "should fetch donations since the last refresh" do
      FA::Donation.should_receive(:find_by_member_id).with(organization.fa_member_id, organization.fiscally_sponsored_project.updated_at - 1.day).and_return([])
      subject.import_recent_fa_donations(organization)
    end
  end

  describe "processing donations" do
    
    describe "when the donation already exists" do
      let(:donation) { Factory(:fa_donation) }
      let(:donor) { Factory(:person) }
    
      it "updates the existing order" do
        order = Factory(:order, :organization => organization, :fa_id => donation.id)
        new_order = subject.send(:create_order, donation, organization)
        new_order.should eq order
      end
    
      it "does not create a new person under any circumstances" do
        order = Factory(:order, :organization => organization, :fa_id => donation.id)
        Person.should_not_receive(:save)
        new_order = subject.send(:create_order, donation, organization)
        new_order.should eq order      
      end
    end
      
    describe "when it is a new donation" do
      let(:donation) { Factory(:fa_donation) }
      
      before(:each) do
        Order.where(:fa_id => donation.id).should be_empty
        @order = subject.send(:create_order, donation, organization)
      end
      
      it "creates a new order if one does not exist for the given fa_id" do
        @order.should_not be_new_record
        @order.id.should_not be_nil
        @order.fa_id.should eq donation.id
      end
    
      it "creates a new person if the person does not exist yet" do
        p = @order.person
        p.should_not be_new_record
        p.first_name.should eq donation.donor.first_name
      end
    end
      
    describe "when it is a new donation with an existing donor email address" do    
      let(:donation) { Factory(:fa_donation) }
      
      it "does not create a person if the donor already exists" do
        Order.where(:fa_id => donation.id).should be_empty
        existing_person = organization.people.create({:email => donation.donor.email})
        organization.people.length.should eq 1
        @order = subject.send(:create_order, donation, organization)
        @order.person.id.should eq existing_person.id
        organization.people.length.should eq 1
      end
    
      it "creates a new person if there is no email address" do
        organization.people.length.should eq 0
        Order.delete_all(:fa_id => donation.id)
        donation.donor.email = nil
        @order = subject.send(:create_order, donation, organization)
        p = @order.person
        p.should_not be_new_record
        organization.people.length.should eq 1
      end
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