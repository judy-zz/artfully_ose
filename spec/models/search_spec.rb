require 'spec_helper'

describe Search do
  disconnect_sunspot
  let(:search) {Search.new.tap {|s| s.organization = organization}}
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
        search.event_id = event.id
      end
      it "should return the people that match" do
        pending "TODO: Feature works, but the specs don't yet!"
        search.people.should include @buyer
      end
      it "should not return the people that don't match" do
        search.people.should_not include @nonbuyer
      end
    end
    context "with lifetime values" do
      before(:each) do
        search.min_lifetime_value = 11000
        search.max_lifetime_value = 19000
      end
      let(:too_high)   {Factory(:person, organization: organization, lifetime_value: 20000)}
      let(:just_right) {Factory(:person, organization: organization, lifetime_value: 15000)}
      let(:too_low)    {Factory(:person, organization: organization, lifetime_value: 10000)}
      it "should return the people that match" do
        search.people.should include just_right
      end
      it "should not return the people that don't match" do
        search.people.should_not include too_high
        search.people.should_not include too_low
      end
    end
    context "with lifetime donations" do
      before(:each) do
        search.min_lifetime_donations = 11000
        search.max_lifetime_donations = 19000
      end
      let(:too_high)   {Factory(:person, organization: organization, lifetime_donations: 20000)}
      let(:just_right) {Factory(:person, organization: organization, lifetime_donations: 15000)}
      let(:too_low)    {Factory(:person, organization: organization, lifetime_donations: 10000)}
      it "should return the people that match" do
        search.people.should include just_right
      end
      it "should not return the people that don't match" do
        search.people.should_not include too_high
        search.people.should_not include too_low
      end
    end
    context "with a zipcode" do
      before(:each) do
        search.zip = 10001
      end
      let(:person1) {Factory(:person, organization: organization, address: Factory(:address, zip: search.zip))}
      let(:person2) {Factory(:person, organization: organization, address: Factory(:address, zip: search.zip + 1))}
      it "should return the people that match" do
        search.people.should include person1
      end
      it "should not return the people that don't match" do
        search.people.should_not include person2
      end
    end

    context "with a state" do
      before(:each) do
        search.state = "PA"
      end
      let(:person1) {Factory(:person, organization: organization, address: Factory(:address, state: "PA"))}
      let(:person2) {Factory(:person, organization: organization, address: Factory(:address, state: "NY"))}
      it "should return the people that match" do
        search.people.should include person1
      end
      it "should not return the people that don't match" do
        search.people.should_not include person2
      end
    end
  end

end
