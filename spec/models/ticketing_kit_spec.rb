require 'spec_helper'

describe TicketingKit do
  subject { Factory(:ticketing_kit) }

  describe "state machine" do
    it { should respond_to :cancel }
    it { should respond_to :cancelled? }
    it { should respond_to :active? }


    it "should start in the active state" do
      subject.should be_active
    end

    it "should change to the cancelled state when cancelled" do
      subject.cancel!
      subject.should be_cancelled
    end
  end
end