require 'spec_helper'

describe Payment::CreditCard do
  subject { Factory(:credit_card) }

  %w( cardNumber expirationDate cardholderName cvv ).each do |attribute|
    it { should respond_to attribute.underscore }
    it { should respond_to attribute.underscore + '=' }
  end

  it "should use the MM/YY format when encoding the expiration date to JSON" do
    @card = Factory(:credit_card)
    @card.to_json.should match(/\"expirationDate\":\"#{@card.expiration_date.strftime('%m\/%Y')}\"/)
  end
end
