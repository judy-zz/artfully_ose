require 'spec_helper'

sample_donation = "<?xml version=\"1.0\" encoding=\"utf-8\"?><donations><donation><id>40951</id><date>2010-06-02</date><amount>10.00</amount><nongift>0.00</nongift><check_no/><is_noncash/><is_stock/><fs_project><id>2353</id><member_id>4052</member_id><name>Everything Under the Sun</name></fs_project><fs_available_on>2010-06-09</fs_available_on><donor><email>support-test@indiegogo.com</email><first_name/><last_name/><company_name/><address1/><address2/><city/><state/><zip/><country>United States</country><anonymous>No</anonymous></donor><is_anonymous/><is_name_only/><memo/><reversed_at>1275603003</reversed_at><reversed_note>Credit card transaction refunded (originally $1)</reversed_note><created_at>2010-06-02 00:00:00</created_at><updated_at>2010-06-02 00:00:00</updated_at></donation><donation><id>40952</id><date>2010-06-02</date><amount>0.00</amount><nongift>0.00</nongift><check_no/><is_noncash/><is_stock/><fs_project><id>2353</id><member_id>4052</member_id><name>Everything Under the Sun</name></fs_project><fs_available_on>2010-06-09</fs_available_on><donor><email>support-test@indiegogo.com</email><first_name/><last_name/><company_name/><address1/><address2/><city/><state/><zip/><country>United States</country><anonymous>No</anonymous></donor><is_anonymous/><is_name_only/><memo/><reversed_at>1275602794</reversed_at><reversed_note>Credit card transaction refunded (originally $1)</reversed_note><created_at>2010-06-02 00:00:00</created_at><updated_at>2010-06-02 00:00:00</updated_at></donation></donations>"
#sample_donation = "<donations><donation></donation><donation></donation></donations>"
sample_single_donation = "<donations><donation><id>40951</id><date>2010-06-02</date><amount>10.00</amount><nongift>50.00</nongift><check_no/><is_noncash/><is_stock/><fs_project><id>2353</id><member_id>4052</member_id><name>Everything Under the Sun</name></fs_project><fs_available_on>2010-06-09</fs_available_on><donor><email>support-test@indiegogo.com</email><first_name>Indie</first_name><last_name>Gogo</last_name><company_name/><address1/><address2/><city/><state/><zip/><country>United States</country><anonymous>No</anonymous></donor><is_anonymous/><is_name_only/><memo/><reversed_at>1275603003</reversed_at><reversed_note>Credit card transaction refunded (originally $1)</reversed_note><created_at>2010-06-02 00:00:00</created_at><updated_at>2010-06-02 00:00:00</updated_at></donation></donations>"

describe FA::Donation do
  let(:donation) { Factory(:sponsored_donation) }
  let(:payment) { Factory(:payment) }
  subject { FA::Donation.from(donation, payment) }

  describe ".find_by_member_id" do
    it "gets the donations from fa" do
      FakeWeb.register_uri(:get, 
                           "http://staging.api.fracturedatlas.org/donations.xml?FsProject.member_id=100",
                           :body => "#{sample_donation}")
      donations = FA::Donation.find_by_member_id("100")
      donations.size.should eq 2
      
    end

    #ActiveResource handles one donation differently (even though the xml is the same)
    #the collection comes out as a hash instead of an array
    it "gets the donations from fa when there is only one" do
      FakeWeb.register_uri(:get, 
                           "http://staging.api.fracturedatlas.org/donations.xml?FsProject.member_id=100",
                            :body => "#{sample_single_donation}")
      donations = FA::Donation.find_by_member_id("100")
      donations.size.should eq 1
      donation = donations.first
      donation.amount.should eq "10.00"
      donation.date.should eq "2010-06-02"
      donation.nongift.should eq "50.00"
      donation.check_no.should eq nil
      donation.is_stock.should eq nil
      donation.fs_available_on.should eq "2010-06-09"
      donation.reversed_at.should eq "1275603003"
      donation.reversed_note.should eq "Credit card transaction refunded (originally $1)"
      donation.created_at.should eq "2010-06-02 00:00:00"
      donation.updated_at.should eq "2010-06-02 00:00:00"
      
      donation.donor.email.should eq "support-test@indiegogo.com"
      donation.donor.first_name.should eq "Indie"
      donation.donor.last_name.should eq "Gogo"
      donation.donor.anonymous.should eq "No"
    end
    
    it "recovers from a 404 with style and grace" do
      FakeWeb.register_uri(:get, 
                           "http://staging.api.fracturedatlas.org/donations.xml?FsProject.member_id=100", 
                           :body => "Not found",
                           :status => ["404", "Not Found"])
      donations = FA::Donation.find_by_member_id("100")
      donations.size.should eq 0
    end
  end

  describe ".from" do
    it "sets the amount based on the donation" do
      subject.amount.should eq donation.amount / 100.00
    end

    it "creates an item that is already settled" do
      subject.settled = donation.organization.fiscally_sponsored_project.fs_project_id
    end

    it "sets the project ID based on the organization" do
      subject.fs_project_id = donation.organization.fiscally_sponsored_project.fs_project_id
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
end