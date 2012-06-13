require 'spec_helper'

describe CreditCardPayment do
  let(:customer){ Factory.build(:customer_with_id) }
  let(:card){ Factory.build(:credit_card) }

  subject { CreditCardPayment.for_card_and_customer(card, customer)}

  it "requires authorization" do
    subject.requires_authorization?.should be_true
  end
  
  describe "amount" do
    it "sets the amount and converts it to dollars" do
      subject.amount = 10002
      subject.amount.should eq 100.02
    end
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
