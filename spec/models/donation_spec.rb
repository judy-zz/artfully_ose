require 'spec_helper'

describe Donation do
  subject { Factory(:donation) }

  it { should be_valid }

  it { should respond_to :amount }
  it { should respond_to :order }

  describe ".amount" do
    it "should not be valid without an amount" do
      subject.amount = nil
      subject.should_not be_valid
    end

    it "should not be valid with an amount less than 0" do
      subject.amount = -1
      subject.should_not be_valid
    end

    it "should not be valid with an amount equal to 0" do
      subject.amount = 0
      subject.should_not be_valid
    end
  end
end
