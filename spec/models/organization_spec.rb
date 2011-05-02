require 'spec_helper'

describe Organization do
  subject { Factory(:organization) }

  it { should respond_to :name }
  it { should respond_to :users }
  it { should respond_to :memberships }

  describe "ability" do
    it { should respond_to :ability }
  end

  describe ".owner" do
    it "should return the first user as the owner of the organization" do
      user = Factory(:user)
      subject.users << user
      subject.owner.should eq user
    end
  end

  describe "kits" do
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
    context "with a Donation Kit" do
      before(:each) do
        subject.kits << Factory(:donation_kit, :state => :activated)
      end

      it "sets authorized to true" do
        subject.authorization_hash[:authorized].should be_true
      end

      it "sets type to sponsored when it is a fiscally sponsored project" do
        subject.authorization_hash[:type].should eq :sponsored
      end

      it "sets type to regular when it is not a fiscally sponsored project" do
        pending "Requires different types of donation kits"
        subject.authorization_hash[:type].should eq :regular
      end
    end

    context "without a Donation Kit" do
      it "sets authorized to false" do
        subject.authorization_hash[:authorized].should be_false
      end
    end
  end

end
