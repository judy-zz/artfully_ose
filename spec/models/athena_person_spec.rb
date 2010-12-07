require 'spec_helper'

describe AthenaPerson do
  subject { Factory(:athena_person) }

  it { should be_valid }
  it { should respond_to :email }

  it "should not be valid with an email address" do
    subject.email = nil
    subject.should_not be_valid
  end

end
