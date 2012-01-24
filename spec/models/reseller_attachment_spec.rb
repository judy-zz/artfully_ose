require 'spec_helper'

describe ResellerAttachment do

  subject { Factory(:reseller_attachment) }

  it "should not be valid without an image attached" do
    subject.should_not be_valid
  end

  it "should be valid with an image attached" do
    subject.image = Rails.root.join("public", "images", "logo.png").open
    subject.should be_valid
  end

end
