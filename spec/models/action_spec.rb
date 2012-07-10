require 'spec_helper'

describe Action do
  disconnect_sunspot
  
  subject { Factory(:get_action) }
  let(:organization) { Factory(:organization)}
  let(:user) { Factory(:user) }
  let(:person) { Factory(:person) }

  before(:all) do
    user.organizations << organization
  end

  describe "#set_params" do
    let(:params) { {occurred_at: DateTime.now} }
    it "should set occurred_at" do
      expect {subject.set_params(params, person)}.to change(subject, :occurred_at)
    end
    it "should not set the creator" do
      lambda { subject.set_params(params, person)}.should_not change(subject, :creator)
    end
  end

  describe "#set_creator" do
    it "should set the creator" do
      expect {subject.set_creator(user)}.to change(subject, :creator)
    end
    it "should set the organization" do
      expect {subject.set_creator(user)}.to change(subject, :organization)
    end
  end

end