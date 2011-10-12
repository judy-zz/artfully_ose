require "spec_helper"

describe OrderMailer do
  describe "order confirmation email" do
    let(:order) { Factory(:order) }
    subject { OrderMailer.confirmation_for(order) }

    before(:each) do
      order.stub(:items).and_return(10.times.collect{ Factory(:item)})
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
