require 'spec_helper'

describe PurchaseAction do
  subject { Factory(:purchase_action) }
  it { should be_valid }

  describe ".valid?" do
    it "should not be valid without a person id" do
      subject.person_id = nil
      subject.should_not be_valid
    end
  end

  describe "subject" do
    it "should return an Order as the subject" do
      pending
    end

    it "should fetch the Order if not cached" do
      pending
    end
  end
end
