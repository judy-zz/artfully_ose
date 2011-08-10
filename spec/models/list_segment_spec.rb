require 'spec_helper'

describe ListSegment do
  subject { Factory(:list_segment) }

  it "returns an empty array if people_ids is nil" do
    subject.people_ids = nil
    subject.people_ids.should be_empty
  end

  it "wraps people_ids in an array if it is a single element" do
    subject.people_ids = "2"
    subject.people_ids.should eq [ "2" ]
  end

  describe "#people=" do
    let(:people) { 3.times.collect { Factory(:athena_person_with_id) } }
    it "updates the people_ids attribute when people are assigned" do
      subject.people = people
      subject.people_ids.should eq people.collect(&:id)
    end
  end
end
