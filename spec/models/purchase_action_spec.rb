require 'spec_helper'

describe PurchaseAction do

  subject { Factory(:purchase_action) }

  it { should be_valid }

  describe "action type" do
    it "should be of type purchase" do
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #{PurchaseAction.new.action_type}"
      PurchaseAction.new.action_type.should eq "Get"
      subject.action_type.should eq "Get"
    end

    it "should not change when assigned a different value" do
      subject.action_type = "other"
      subject.action_type.should eq "Get"
    end
  end

  describe ".valid?" do
    it "should not be valid without a person id" do
      subject.person_id = nil
      subject.should_not be_valid
    end
  end

  describe "subject" do
    it "should return an Order as the subject"
    it "should fetch the Order if not cached"
  end

end
