require 'spec_helper'

describe Athena::Customer do
  subject { Factory(:customer) }

  %w( firstName lastName phone email ).each do |attribute|
    it { should respond_to attribute.underscore }
    it { should respond_to attribute.underscore + '=' }
  end

  %w( firstName lastName email ).each do |attribute|
    it "should not be valid if #{attribute.underscore} is blank" do
      subject = Factory(:customer, attribute.underscore => nil)
      subject.should_not be_valid
      subject.errors.size.should == 1
    end
  end
end
