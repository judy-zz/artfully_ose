require 'spec_helper'

require 'spec_helper'

describe AthenaDonationAction do

  subject { Factory(:athena_donation_action) }

  it { should be_valid }

  describe "action type" do
    it "should be of type donation" do
      AthenaDonationAction.new.action_type.should eq "donation"
      subject.action_type.should eq "donation"
    end

    it "should not change when assigned a different value" do
      subject.action_type = "other"
      subject.action_type.should eq "donation"
    end
  end

  describe ".valid?" do
    it "should not be valid without a person id" do
      subject.person_id = nil
      subject.should_not be_valid
    end

    it "should not be valid without an subject id" do
      subject.subject_id = nil
      subject.should_not be_valid
    end
  end

  describe "subject" do
    it "should return a Donation as the subject" do
      subject.subject.should be_a Donation
    end

    it "should fetch the Donation if not cached" do
      donation = subject.subject
      subject.instance_variable_set(:@subject, nil)
      subject.subject.should eq donation
    end
  end

end
