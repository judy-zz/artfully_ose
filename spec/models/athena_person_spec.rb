require 'spec_helper'

describe AthenaPerson do
  subject { Factory(:athena_person) }

  it { should be_valid }
  it { should respond_to :email }

  it "should not be valid with an email address" do
    subject.email = nil
    subject.should_not be_valid
  end

  it "should return the user with a matching athena_id" do
    subject = Factory(:athena_person_with_id)
    user = Factory(:user, :athena_id => subject.id)
    subject.user.should eq user
  end

  describe "#find_by_email" do
    it "should search for the Person by email address" do
      AthenaPerson.stub(:find).and_return([])
      AthenaPerson.should_receive(:find).with(:all, :params => {:email => "eqperson@example.com"})
      AthenaPerson.find_by_email("person@example.com")
    end
  end

end
