require 'spec_helper'

describe FA::Donation do
  let(:donation) { Factory(:sponsored_donation) }
  let(:payment) { Factory(:payment) }
  subject { FA::Donation.from(donation, payment) }

  describe ".from" do
    it "sets the amount based on the donation" do
      subject.amount.should eq donation.amount / 100.00
    end

    it "sets the project ID based on the organization" do
      subject.fs_project_id = donation.organization.fa_project_id
    end
  end

  describe "#to_xml" do
    it "includes the attributes in xml" do
      subject.to_xml.should match /amount/
      subject.to_xml.should match /fs_project_id/
    end

    it "includes the credit card" do
      attributes = Hash.from_xml(subject.to_xml)
      subject.credit_card.attributes.should eq attributes['donation']['credit_card']
    end

    it "includes the donor information" do
      attributes = Hash.from_xml(subject.to_xml)
      subject.donor.attributes.should eq attributes['donation']['donor']
    end
  end

  describe FA::Donation::CreditCard do
    let(:payment) { Factory(:payment) }
    subject { FA::Donation::CreditCard.extract_from(payment) }

    describe ".extract_from" do
      it "capture credit card information from the payment" do
        subject.number.should     == payment.credit_card.card_number
        subject.expiration.should == payment.credit_card.expiration_date.strftime('%m/%Y')
        subject.zip.should        == payment.billing_address.postal_code
        subject.code.should       == payment.credit_card.cvv
      end
    end
  end

  describe FA::Donation::Donor do
    let(:payment) { Factory(:payment) }
    subject { FA::Donation::Donor.extract_from(payment) }

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
  end
end