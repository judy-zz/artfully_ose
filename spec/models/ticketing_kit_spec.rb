require 'spec_helper'

describe TicketingKit do
  subject { Factory(:ticketing_kit) }

  describe "state machine" do
    it { should respond_to :cancel }
    it { should respond_to :cancelled? }
    it { should respond_to :active? }


    it "should start in the new state" do
      subject.should be_new
    end

    it "should not transition to active if the user does not have a credit card" do
      subject.user.stub!(:credit_cards).and_return([])
      subject.activate!
      subject.should_not be_active
    end

    it "should change from activated to cancelled when cancelled" do
      subject.state = :active
      subject.cancel!
      subject.should be_cancelled
    end
  end

  describe ".valid?" do
    it "should be valid with a valid user" do
      subject.user.should be_valid
      subject.should be_valid
    end

    it "should not be valid unless associated with a user" do
      subject.stub(:user).and_return(nil)
      subject.should_not be_valid
    end

    it "should be valid if the user has at least one credit card" do
      subject.user.credit_cards << Factory(:credit_card)
      subject.should be_valid
    end
  end
end