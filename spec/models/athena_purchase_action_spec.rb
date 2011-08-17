require 'spec_helper'

describe AthenaPurchaseAction do

  subject { Factory(:athena_purchase_action) }

  it { should be_valid }

  describe "action type" do
    it "should be of type purchase" do
      AthenaPurchaseAction.new.action_type.should eq "Get"
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
    it "should return an AthenaOrder as the subject" do
      subject.subject.should be_an AthenaOrder
    end

    it "should fetch the AthenaOrder if not cached" do
      order = subject.subject
      subject.instance_variable_set(:@subject, nil)
      subject.subject.should eq order
    end
  end

end
