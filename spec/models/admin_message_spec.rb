require 'spec_helper'

describe AdminMessage do

  context "an admin message that expired yesterday" do
    subject { Factory.create :admin_message, :starts_on => Date.yesterday, :ends_on => Date.yesterday }
    
    it "should not be in the active list" do
      subject.save
      AdminMessage.active.count.should == 0
    end
  end

  context "an admin message that expires tomorrow" do
    subject { Factory.create :admin_message, :message => 'hi', :starts_on => Date.yesterday, :ends_on => Date.tomorrow }
    before { subject } # Make sure subject is loaded.

    it "should be in the active list" do
      subject.save
      AdminMessage.active.should eq Array.wrap(subject)
    end
  end

end
