require 'spec_helper'

describe AthenaAddress do
  before(:each) do
    @address = Factory(:address)
  end

  %w( street_address1 city state postal_code ).each do |attribute|
    it "should not be valid if #{attribute} is blank" do
      @address = Factory(:address, attribute => nil)
      @address.should_not be_valid
      @address.errors.size.should == 1
    end
  end
end
