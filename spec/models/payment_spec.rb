require 'spec_helper'

describe Payment do

  before(:each) do
    @payment = Factory(:payment)
  end

  it "should include amount" do
    @payment.respond_to?(:amount).should be_true
  end


  it "should be valid with an amount set" do
    @payment.amount = 10.00
    @payment.should be_valid
  end

  it "should be invalid without an amount" do
    @payment.amount = nil
    @payment.should_not be_valid
  end

  it "should be invalid with an amount less than zero" do
    @payment.amount = -10.00
    @payment.should_not be_valid
  end

end
