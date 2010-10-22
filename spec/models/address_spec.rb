require 'spec_helper'

describe Address do
  before(:each) do
    @address = Factory(:address)
  end

  %w( firstName lastName company streetAddress city state postalCode country ).each do |attribute|
    it "should respond to #{attribute.underscore}" do
      @address.respond_to?(attribute.underscore).should be_true
    end

    it "should respond to #{attribute.underscore}=" do
      @address.respond_to?(attribute.underscore + '=').should be_true
    end
  end

  %w( firstName lastName company streetAddress city state postalCode country ).each do |attribute|
    it "should not be valid if #{attribute.underscore} is blank" do
      @address = Factory(:address, attribute.underscore => nil)
      @address.should_not be_valid
      @address.errors.size.should == 1
    end
  end
end
