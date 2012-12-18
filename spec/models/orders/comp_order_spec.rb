require 'spec_helper'

describe CompOrder do
  disconnect_sunspot
  subject { FactoryGirl.build(:comp_order) }

  describe "refundable_items" do
    it "shouldn't allow refunds" do
      subject.items << FactoryGirl.create(:comped_item)
      subject.refundable_items.length.should eq 0
    end
  end
end