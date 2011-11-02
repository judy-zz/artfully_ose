require 'spec_helper'

describe AthenaAddress do
  %w( street_address1 city state postal_code ).each do |attribute|
    subject { Factory(:athena_address, attribute => nil) }

    it "is not be valid if #{attribute} is blank" do
      subject.should_not be_valid
      subject.errors.size.should == 1
    end
  end
end
