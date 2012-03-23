require 'spec_helper'

describe FA::Donor do
  let(:payment) { Factory(:payment) }
  subject { FA::Donor.extract_from(payment) }

  describe ".extract_from" do
    it "captures donor information from the payment" do
      subject.email.should      == payment.customer.email
      subject.first_name.should == payment.customer.first_name
      subject.last_name.should  == payment.customer.last_name
      subject.address1.should   == payment.billing_address.street_address1
      subject.city.should       == payment.billing_address.city
      subject.state.should      == payment.billing_address.state
      subject.zip.should        == payment.billing_address.postal_code
    end
  end
  
  it "should say it has keys if email is present" do
    subject.should have_keys
    subject.email = nil
    subject.should_not have_keys
  end
end