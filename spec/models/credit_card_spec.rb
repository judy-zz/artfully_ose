require 'spec_helper'

describe CreditCard do
  before(:each) do
    @card = CreditCard.new
  end

  %w( number expirationDate cardholderName cvv ).each do |attribute|
    it "should respond to #{attribute.underscore}" do
      @card.respond_to?(attribute.underscore).should be_true
    end

    it "should respond to #{attribute.underscore}=" do
      @card.respond_to?(attribute.underscore + '=').should be_true
    end
  end
end
