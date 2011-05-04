require 'spec_helper'

describe Kit do

  subject { Kit.new }

  describe ".pad_with_new_kits" do
    it "fills an empty array with a new instance of each type of kit" do
      Kit.pad_with_new_kits([]).collect(&:class).should eq Kit.subklasses
    end

    it "does not create a new instance if the array has one of that type" do
      kits = Array.wrap(Factory(:ticketing_kit))
      padded = Kit.pad_with_new_kits(kits)
      padded.select{ |kit| kit.type == "TicketingKit" }.should have(1).kit
    end
  end

  describe "#alternatives" do
    it "returns an empty array" do
      subject.alternatives.should be_empty
    end

    it "has no alternatives" do
      subject.should_not have_alternatives
    end
  end
end
