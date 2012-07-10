require 'spec_helper'

describe Search do
  disconnect_sunspot
  subject {Search.new.tap {|s| s.organization = organization}}
  let(:organization) {Factory(:organization)}

  describe "#people" do
    context "with an event" do
      before(:each) do
        event = Factory(:event, organization: organization).tap{|e| e.save!}
        show = Factory(:show, event: event).tap{|e| e.save!}
        ticket = Factory(:ticket, show: show).tap{|e| e.save!}
        @buyer = Factory(:person, organization: organization).tap{|e| e.save!}
        @nonbuyer = Factory(:person, organization: organization).tap{|e| e.save!}
        ticket.sell_to @buyer
        subject.event_id = event.id
      end
      it "should return the people that match" do
        subject.people.should include @buyer
      end
      it "should not return the people that don't match" do
        subject.people.should_not include @nonbuyer
      end
    end
    context "with a lifetime value" do
      before(:each) do
        subject.lifetime_value = 15000
      end
      let(:person1) {Factory(:person, organization: organization, lifetime_value: 20000)}
      let(:person2) {Factory(:person, organization: organization, lifetime_value: 10000)}
      it "should return the people that match" do
        subject.people.should include person1
      end
      it "should not return the people that don't match" do
        subject.people.should_not include person2
      end
    end
    context "with a zipcode" do
      before(:each) do
        subject.zip = 10001
      end
      let(:person1) {Factory(:person, organization: organization, address: Factory(:address, zip: subject.zip))}
      let(:person2) {Factory(:person, organization: organization, address: Factory(:address, zip: subject.zip + 1))}
      it "should return the people that match" do
        subject.people.should include person1
      end
      it "should not return the people that don't match" do
        subject.people.should_not include person2
      end
    end

    context "with a state" do
      before(:each) do
        subject.state = "PA"
      end
      let(:person1) {Factory(:person, organization: organization, address: Factory(:address, state: "PA"))}
      let(:person2) {Factory(:person, organization: organization, address: Factory(:address, state: "NY"))}
      it "should return the people that match" do
        subject.people.should include person1
      end
      it "should not return the people that don't match" do
        subject.people.should_not include person2
      end
    end
  end

end
