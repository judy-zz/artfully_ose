require 'spec_helper'

describe AthenaLock do
  subject { Factory(:lock) }

  describe "attributes" do
    it { should be_valid }
    it { should respond_to :tickets }
    it { should respond_to :lock_expires }
    it { should respond_to :locked_by_api }
    it { should respond_to :locked_by_ip }
    it { should respond_to :status }
  end

  describe "#valid?" do
    it "parses the lock_expires attribute before validation" do
      subject.lock_expires.acts_like_time?.should be_true
    end
  end

  describe "#tickets" do
    it "is an empty array when no ticket ids are specified" do
      subject.tickets.should be_empty
    end
  end

  it "should not be valid with if lock_expires as passed" do
    Factory(:expired_lock).should_not be_valid
  end

  it "should include ticket IDs when encoded" do
    subject.tickets << "2"
    subject.encode.should =~ /\"tickets\":\[\"2\"\]/
  end
end
