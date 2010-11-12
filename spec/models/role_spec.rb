require 'spec_helper'

describe Role do
  subject { Factory(:role) }
  it { should respond_to :users }
end

describe "for producers" do
  it "should use a named scope" do
    @role = Role.producer
    @role.name.should eql("producer")
  end
end
