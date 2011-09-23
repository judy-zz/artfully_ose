require 'spec_helper'

describe CreditCardPayment do
  let(:customer){ Factory(:customer_with_id) }
  let(:card){ Factory(:credit_card) }

  subject { CreditCardPayment.for_card_and_customer(card, customer)}

  it "requires authorization" do
    subject.requires_authorization?.should be_true
  end

  describe ".for_card_and_customer" do
    it "creates a new credit card payment" do
      CreditCardPayment.should_receive(:new).and_return(mock(:payment, :customer= => nil))
      CreditCardPayment.for_card_and_customer(card, customer)
    end

    it "sets the customer and card" do
      subject.customer.should == customer
      subject.credit_card.should == card
    end
  end
end
