require 'spec_helper'

describe AthenaAddress do
  before(:each) do
    @address = Factory(:address)
  end

  %w( firstName lastName company streetAddress1 streetAddress2 city state postalCode country ).each do |attribute|
    it { should respond_to attribute.underscore }
    it { should respond_to attribute.underscore + '=' }
  end

  %w( firstName lastName streetAddress1 city state postalCode ).each do |attribute|
    it "should not be valid if #{attribute.underscore} is blank" do
      @address = Factory(:address, attribute.underscore => nil)
      @address.should_not be_valid
      @address.errors.size.should == 1
    end
  end
end
