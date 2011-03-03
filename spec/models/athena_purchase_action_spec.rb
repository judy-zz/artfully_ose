require 'spec_helper'

describe AthenaPurchaseAction do

  subject { Factory(:athena_purchase_action) }

  it { should be_valid }

  describe "type" do
    it "should be of type purchase" do
      AthenaPurchaseAction.new.type.should eq "purchase"
      subject.type.should eq "purchase"
    end

    it "should not change when assigned a different value" do
      subject.type = "other"
      subject.type.should eq "purchase"
    end
  end

  describe ".valid?" do
    it "should not be valid without a person id" do
      subject.person_id = nil
      subject.should_not be_valid
    end

    it "should not be valid without an item id" do
      subject.item_id = nil
      subject.should_not be_valid
    end

    it "should not be valid without an item type" do
      subject.item_type = nil
      subject.should_not be_valid
    end
  end

end
