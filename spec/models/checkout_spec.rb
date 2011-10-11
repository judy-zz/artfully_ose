require 'spec_helper'

describe Checkout do
  let(:payment) { Factory(:payment) }
  let(:order) { Factory(:order) }

  subject { Checkout.new(order, payment) }

  it "should set the amount for the payment from the order" do
    subject.payment.amount.should eq order.total
  end

  it "should not be valid without a payment if the order total > 0 (Not Free)" do
    subject = Checkout.new(Factory(:order_with_items), payment)
    subject.payment = nil
    subject.should_not be_valid
  end

  it "should be valid without a payment if the order total is 0 (Free)" do
    subject.payment.credit_card = nil
    subject.should be_valid
  end

  it "should not be valid without an order" do
    subject.order = nil
    subject.should_not be_valid
  end

  it "should not be valid if the payment is invalid and order total > 0 (Not Free)" do
    subject = Checkout.new(Factory(:order_with_items), payment)
    subject.payment.stub(:valid?).and_return(false)
    subject.should_not be_valid
  end

  it "should not be valid if the payment is invalid but the order total is 0 (Free)" do
    subject.payment.stub(:valid?).and_return(false)
    subject.should_not be_valid
  end

  describe "cash payments" do
    let(:payment)         { CashPayment.new(Factory(:athena_person)) }
    let(:order_with_item) { Factory(:order_with_items) }
    subject               { Checkout.new(order_with_item, payment) }

    it "should always approve orders with cash payments" do
      subject.stub(:create_order).and_return(AthenaOrder.new)
      subject.stub(:find_or_create_people_record).and_return(Factory(:person))
      subject.finish.should be_true
    end
  end

  describe "#finish" do
    before(:each) do
      subject.order.stub(:pay_with)
    end

    describe "return value" do
      before(:each) do
        subject.stub(:find_or_create_people_record).and_return(Factory(:person))
      end

      it "returns true if the order was approved" do
        subject.order.stub(:approved?).and_return(true)
        subject.finish.should be_true
      end

      it "returns false if the order is not approved" do
        subject.order.stub(:approved?).and_return(false)
        subject.finish.should be_false
      end
    end

    describe "people creation" do
      let(:email){ payment.customer.email }
      let(:organization){ Factory(:organization) }
      let(:attributes){
        { :email           => email,
          :organization_id => organization.id,
          :first_name      => payment.customer.first_name,
          :last_name       => payment.customer.last_name
        }
      }

      it "should create a person record when finishing with a new customer" do
        subject.order.stub(:organizations_from_tickets).and_return(Array.wrap(organization))
        Person.should_receive(:find_by_email_and_organization).with(email, organization).and_return(nil)
        Person.should_receive(:create).with(attributes).and_return(Factory(:athena_person,attributes))
        subject.finish
      end

      it "should not create a person record when the person already exists" do
        subject.order.stub(:organizations_from_tickets).and_return(Array.wrap(organization))
        Person.should_receive(:find_by_email_and_organization).with(email, organization).and_return(Factory(:athena_person,attributes))
        Person.should_not_receive(:create)
        subject.finish
      end
    end
  end
end
