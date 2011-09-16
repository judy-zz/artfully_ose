require 'spec_helper'

describe Organization do
  subject { Factory(:organization) }

  it { should respond_to :name }
  it { should respond_to :users }
  it { should respond_to :memberships }

  describe "ability" do
    it { should respond_to :ability }
  end
  
  describe "refreshing_fa_project" do
    it "should not refresh if fa_member_id is not set" do
      o = subject.refresh_active_fs_project
      o.fa_member_id.should be_nil
    end
    
    it "should refresh" do
      fa_project = Factory(:fa_project)
      FA::Project.stub(:find_by_member_id).and_return(fa_project)
      subject.fa_member_id = fa_project.id
      subject.refresh_active_fs_project
      subject.fiscally_sponsored_project.should_not be_nil
    end
  end
  
  describe ".owner" do
    it "should return the first user as the owner of the organization" do
      user = Factory(:user)
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
      kit = Factory(:ticketing_kit)
      kit.should_receive(:activate!)
      subject.kits << kit
    end

    it "should not attempt to activate the kit if is new before saving" do
      kit = Factory(:ticketing_kit, :state => :activated)
      kit.should_not_receive(:activate!)
      subject.kits << kit
    end
  end

  describe "#authorization_hash" do
    context "with a Regular Donation Kit" do
      before(:each) do
        subject.kits << Factory.build(:regular_donation_kit, :state => :activated, :organization => subject)
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
        subject.kits << Factory.build(:sponsored_donation_kit, :state => :activated, :organization => subject)
      end

      it "sets authorized to true" do
        subject.authorization_hash[:authorized].should be_true
      end

      it "sets type to regular when it is not a fiscally sponsored project" do
        subject.authorization_hash[:type].should eq :sponsored
      end
    end

    context "without a Donation Kit" do
      it "sets authorized to false" do
        subject.authorization_hash[:authorized].should be_false
      end
    end
  end
end
