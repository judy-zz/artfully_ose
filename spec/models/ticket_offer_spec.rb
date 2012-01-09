require 'spec_helper'

describe TicketOffer do

  subject { Factory(:ticket_offer) }

  it "should be valid" do
    subject.should be_valid
  end

  it "should validate the existence of its organization" do
    subject.organization = nil
    subject.should_not be_valid
  end

  it "should not raise an exception when offering a ticket in sequence" do
    subject.status = "creating"
    expect { subject.offer! }.should_not raise_error
  end

  it "should raise an exception when offering a ticket out of sequence" do
    subject.status = "completed"
    expect { subject.offer! }.should raise_error
  end

end
