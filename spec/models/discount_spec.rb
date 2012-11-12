require 'spec_helper'

describe Discount do
  disconnect_sunspot
  subject { FactoryGirl.build(:discount) }
  let(:event) { subject.event }

  it "should be a valid discount" do
    subject.should be_valid
    subject.errors.should be_blank
  end

  specify "should not allow more than one of the same code in the same event" do
    @discount1 = FactoryGirl.build(:discount, code: "ALPHA", event: event)
    @discount2 = FactoryGirl.build(:discount, code: "ALPHA", event: event)
    @discount1.save.should be_true
    @discount2.save.should be_false
  end

  specify "should allow more than one of the same code in different events" do
    @event2 = FactoryGirl.build(:event)
    @discount1 = FactoryGirl.build(:discount, code: "ALPHA", event: event)
    @discount2 = FactoryGirl.build(:discount, code: "ALPHA", event: @event2)
    @discount1.save.should be_true
    @discount2.save.should be_true
  end

  specify "should not allow a code less than 4 characters" do
    FactoryGirl.build(:discount, code: "ABC").save.should be_false
  end

  specify "should not allow a code more than 15 characters" do
    FactoryGirl.build(:discount, code: "BETTERCALLKENNYLOGGINSBECAUSEYOUREINTHEDANGERZONE").save.should be_false
  end
  
  describe "#set_organization_from_event" do
    it "should set the organization from the event's organization" do
      subject.organization = nil
      subject.set_organization_from_event
      subject.organization.should == event.organization
    end
  end

  describe "#apply_discount_to_cart" do
    before(:each) do
      @cart = FactoryGirl.create(:cart_with_items)
      subject.event = @cart.tickets.first.event
    end
    context "with ten percent off" do
      before(:each) do
        subject.promotion_type = "PercentageOffTickets"
      end
      it "should take ten percent off the cost of each ticket" do
        @cart.total.should == 16600
        subject.apply_discount_to_cart(@cart)
        @cart.total.should == 15100 # 14500 + 600 in ticket fees that still apply
      end
    end
    context "with ten dollars off the order" do
      before(:each) do
        subject.promotion_type = "DollarsOffTickets"
      end
      it "should take ten dollars off the cost of each ticket" do
        @cart.total.should == 16600
        subject.apply_discount_to_cart(@cart)
        @cart.total.should == 13600
      end
    end
  end
end
