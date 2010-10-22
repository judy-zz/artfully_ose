require 'spec_helper'

describe Address do
  before(:each) do
    @address = Address.new
  end

  %w( firstName lastName company streetAddress city state postalCode country ).each do |attribute|
    it "should respond to #{attribute.underscore}" do
      @address.respond_to?(attribute.underscore).should be_true
    end

    it "should respond to #{attribute.underscore}=" do
      @address.respond_to?(attribute.underscore + '=').should be_true
    end
  end
end
