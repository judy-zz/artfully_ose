require 'spec_helper'

describe Organization do
  subject { Factory(:organization) }

  it { should respond_to :name }
  it { should respond_to :users }
  it { should respond_to :memberships }

  describe "ability" do
    it { should respond_to :ability }

    it "should delegate can to it's ability" do
      subject.ability.should_receive(:can?)
      subject.can?
    end

    it "should delegate can to it's ability" do
      subject.ability.should_receive(:cannot?)
      subject.cannot?
    end
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

end
