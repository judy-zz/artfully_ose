require 'spec_helper'

describe RegularDonationKit do

  subject { Factory(:regular_donation_kit) }

  describe "state machine" do
    it { should respond_to :cancel }
    it { should respond_to :cancelled? }
    it { should respond_to :activated? }


    it "should start in the new state" do
      subject.should be_new
    end
  end

  describe "approval" do
    it "should transition to pending on the first activation attempt" do
      subject.activate!
      subject.should be_pending
    end
  end

  describe "abilities" do
    subject { Factory(:regular_donation_kit, :state => "activated") }

    it "should return a block for the Ability to use" do
      subject.abilities.should be_a Proc
    end

    it "should grant the organization the ability to receive donations" do
      organization = Factory(:organization)
      organization.kits << subject
      organization.should be_able_to :receive, Donation
    end
  end
end
