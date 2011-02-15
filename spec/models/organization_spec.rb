require 'spec_helper'

describe Organization do
  subject { Factory(:organization) }

  it { should respond_to :name }
  it { should respond_to :users }
  it { should respond_to :memberships }

  describe "ability" do
    it { should respond_to :ability }

    it "should delegate can to it's ability" do
      subject.ability.should_receive(:can?)
      subject.can?
    end

    it "should delegate can to it's ability" do
      subject.ability.should_receive(:cannot?)
      subject.cannot?
    end
  end
end
