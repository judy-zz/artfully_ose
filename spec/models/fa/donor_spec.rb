require 'spec_helper'

describe FA::Donor do
  let(:payment) { Factory.build(:payment) }
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
  
  #It seems stupid to test xml serialization, but this has broken twice on us: once on the move from Ruby 1.8 to 1.9, 
  # and again on Rails 3.0 -> Rails 3.2
  #So, now we serialize by hand and we have a test.
  it "should serialize to xml in order" do
    s = subject.to_xml
    target_xml = ("<?xmlversion=\"1.0\"encoding=\"utf-8\"?><donor><email>"+subject.email+"</email><first-name>"+subject.first_name+"</first-name><last-name>"+subject.last_name+"</last-name><address1>"+subject.address1+"</address1><city>"+subject.city+"</city><state>"+subject.state+"</state><zip>"+subject.zip+"</zip><country>US</country></donor>").gsub(/\s/,'').downcase
    s.gsub(/\s/,'').downcase.should eq target_xml
  end
end