require 'spec_helper'

describe Discount do
  disconnect_sunspot
  subject { FactoryGirl.build(:discount) }
  let(:event) { subject.event }

  it "should be a valid discount" do
    subject.should be_valid
    subject.errors.should be_blank
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
    end
    context "with ten percent off" do
      before(:each) do
        subject.promotion_type = "TenPercentOffTickets"
      end
      it "should take ten percent off the cost of each of the tickets" do
        @cart.total.should == 16600
        subject.apply_discount_to_cart(@cart)
        @cart.total.should == 15100 # 14500 + 600 in ticket fees that still apply
      end
    end
    context "with ten dollars off the order" do
      before(:each) do
        subject.promotion_type = "TenDollarsOffOrder"
      end
      it "should take ten dollars off the entire order" do
        @cart.total.should == 16600
        subject.apply_discount_to_cart(@cart)
        @cart.total.should == 15600
      end
    end
  end
end
