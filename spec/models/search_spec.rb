require 'spec_helper'

describe Search do
  disconnect_sunspot
  subject {Search.new.tap {|s| s.organization = organization}}
  let(:organization) {Factory(:organization)}

  describe "#people" do
    context "with a zipcode" do
      before(:each) do
        subject.zip = 10001
      end
      let(:person1) {Factory(:person, organization: organization, address: Factory(:address, zip: subject.zip))}
      let(:person2) {Factory(:person, organization: organization, address: Factory(:address, zip: subject.zip + 1))}
      it "should return a list of people that match the criteria" do
        subject.people.should     include person1
        subject.people.should_not include person2
      end
    end
  end

end
