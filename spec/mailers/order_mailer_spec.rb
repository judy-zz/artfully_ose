require "spec_helper"

describe OrderMailer do
  describe "order confirmation email" do
    let(:order) { Factory(:order_with_items) }
    let(:athena_order) { Factory(:athena_order_with_id) }
    subject { OrderMailer.confirmation_for(order, athena_order) }

    before(:each) do
      subject.deliver
    end

    it "should send a confirmation email to the user" do
      ActionMailer::Base.deliveries.should_not be_empty
    end

    it "should have a subject" do
      subject.subject.should_not be_blank
      subject.subject.should eq "Your Order"
    end

    it "should be sent to the owner of the order" do
      subject.to.should_not be_blank
      subject.to.should include order.person.email
    end
  end
end
