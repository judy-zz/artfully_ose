require 'spec_helper'

describe AthenaRelationship do

  subject { Factory(:athena_relationship) }

  describe "as a remote resource" do
    it "should use the prefix /tix/meta/" do
      FakeWeb.register_uri(:get, "http://localhost/people/meta/relationships/.json", :status => 200, :body => "[]")
      AthenaRelationship.all
      FakeWeb.last_request.path.should == "/people/meta/relationships/.json"
    end
  end

  describe "attributes" do
    it { should respond_to :left_side_id }
    it { should respond_to :right_side_id }
    it { should respond_to :relationship_type }
    it { should respond_to :inverse_type }
  end

  describe ".valid?" do
    it "should not be valid without a relationship type" do
      subject.relationship_type = nil
      subject.should_not be_valid
      subject.errors.should have(1).error
    end

    it "should not be valid without an inverse relationship type" do
      subject.inverse_type = nil
      subject.should_not be_valid
      subject.errors.should have(1).error
    end

    it "should not be valid without a subject" do
      subject.left_side_id = nil
      subject.should_not be_valid
      subject.errors.should have(1).error
    end

    it "should not be valid without an object" do
      subject.right_side_id = nil
      subject.should_not be_valid
      subject.errors.should have(1).error
    end
  end

  describe "the members of the relationship" do
    it { should respond_to :subject }
    it { should respond_to :object }

    it "should find the People record for the subject of the relationship" do
      subject.subject.should be_an(AthenaPerson)
      subject.subject.id.should eq subject.left_side_id
    end

    it "should find the People record for the object of the relationship" do
      subject.object.should be_an(AthenaPerson)
      subject.object.id.should eq subject.right_side_id
    end
  end

  describe "#find_by_person" do
    it "should request the relationships based on the person's id" do
      person = Factory(:person_with_id)
      FakeWeb.register_uri(:get, "http://localhost/people/meta/relationships/people/#{person.id}.json", :body => "[]")
      AthenaRelationship.find_by_person(person)
      FakeWeb.last_request.path.should eq "/people/meta/relationships/people/#{person.id}.json"
    end

    it "should request the relationships when only given an id" do
      FakeWeb.register_uri(:get, "http://localhost/people/meta/relationships/people/1.json", :body => "[]")
      AthenaRelationship.find_by_person(1)
      FakeWeb.last_request.path.should eq "/people/meta/relationships/people/1.json"
    end
  end

end
