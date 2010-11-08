require 'spec_helper'

describe Payment::Customer do
  before(:each) do
    @customer = Factory(:customer)
  end

  %w( firstName lastName phone email ).each do |attribute|
    it "should respond to #{attribute.underscore}" do
      @customer.respond_to?(attribute.underscore).should be_true
    end

    it "should respond to #{attribute.underscore}=" do
      @customer.respond_to?(attribute.underscore + '=').should be_true
    end
  end

  %w( firstName lastName email ).each do |attribute|
    it "should not be valid if #{attribute.underscore} is blank" do
      @customer = Factory(:customer, attribute.underscore => nil)
      @customer.should_not be_valid
      @customer.errors.size.should == 1
    end
  end
end
