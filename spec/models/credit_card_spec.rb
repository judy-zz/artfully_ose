require 'spec_helper'

describe CreditCard do
  before(:each) do
    @card = CreditCard.new
  end

  %w( cardNumber expirationDate cardholderName cvv ).each do |attribute|
    it { should respond_to attribute.underscore }
    it { should respond_to attribute.underscore + '=' }
  end
end
