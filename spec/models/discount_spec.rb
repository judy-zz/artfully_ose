require 'spec_helper'

describe Discount do
  disconnect_sunspot
  subject { FactoryGirl.build(:discount) }

  it "should be a valid discount" do
    subject.should be_valid
    subject.errors.should be_blank
  end
end
