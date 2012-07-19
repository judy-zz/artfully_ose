require 'spec_helper'

describe Search do
  disconnect_sunspot
  let(:search) {Search.new.tap {|s| s.organization = organization}}
  let(:organization) {Factory(:organization)}

  describe "#people" do
    context "with an event" do
      before(:each) do
        @event = Factory(:event, organization: organization)
        @show = Factory(:show, event: @event)
        @ticket = Factory(:ticket, show: @show)
        @buyer = Factory(:person, organization: organization)
        @nonbuyer = Factory(:person, organization: organization)
        @ticket.put_on_sale
        @ticket.sell_to @buyer
        search.event_id = @event.id
      end
      it "should return the people that match" do
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

    context "with a range of donations" do
      let(:person1) {Factory(:person, organization: organization)}
      let(:person2) {Factory(:person, organization: organization)}
      before(:each) do
        search.min_donations_date   = 1.month.ago
        search.max_donations_date   = 1.month.from_now
        search.min_donations_amount = 500
        search.max_donations_amount = 1500
        # Each donation item should be worth $10.
        Factory(:order, created_at: 2.months.ago,      person: person1) << Factory(:donation)
        Factory(:order, created_at: Time.now,          person: person1) << Factory(:donation)
        Factory(:order, created_at: 2.months.from_now, person: person1) << Factory(:donation)
        Factory(:order, created_at: Time.now,          person: person2) << Factory(:donation, amount: 2500)
      end
      it "should return the people that match" do
        search.people.should include person1
      end
      it "should not return the people that don't match" do
        search.people.should_not include person2
      end
    end

    context "with a range of donation dates but no amounts" do
      let(:person1) {Factory(:person, organization: organization)}
      let(:person2) {Factory(:person, organization: organization)}
      before(:each) do
        search.min_donations_date   = 1.month.ago
        search.max_donations_date   = 1.month.from_now
        # Each donation item should be worth $10.
        Factory(:order, created_at: Time.now, person: person1) << Factory(:donation, amount: 1000)
        Factory(:order, created_at: Time.now, person: person2) << Factory(:ticket)
      end
      it "should return the first person with a higher donation amount" do
        search.people.should include person1
      end
      it "should not return the people with no donations (or donations of less than a dollar)" do
        search.people.should_not include person2
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
