require 'spec_helper'

describe Discount do
  disconnect_sunspot
  subject { FactoryGirl.build(:discount) }
  let(:event) { subject.event }

  it "should be a valid discount" do
    subject.should be_valid
    subject.errors.should be_blank
  end

  describe "#set_organization_from_event" do
    it "should set the organization from the event's organization" do
      subject.organization = nil
      subject.set_organization_from_event
      subject.organization.should == event.organization
    end
  end
end
