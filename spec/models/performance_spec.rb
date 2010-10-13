require 'spec_helper'

describe Performance do
  it "should be invalid with an empty title" do
    @performance = Factory.build(:performance, :title => nil)
    @performance.title.should be_nil
    @performance.should_not be_valid
  end

  it "should be invalid for with an empty venue" do
    @performance = Factory.build(:performance, :venue => nil)
    @performance.venue.should be_nil
    @performance.should_not be_valid
  end
  
  it "should be invalid for with an empty performance date" do
    @performance = Factory.build(:performance, :performed_on => nil)
    @performance.performed_on.should be_nil
    @performance.should_not be_valid
  end

  it "should be valid with a title, venue, and date" do
    @performance = Factory(:performance)
    @performance.should be_valid
  end
end
