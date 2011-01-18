require 'spec_helper'

describe Ability do
  describe "Admins" do
  end

  describe "Producers" do
    subject { Ability.new(Factory(:producer)) }

    it { should_not be_able_to(:destroy, Factory(:athena_performance, :tickets_created => true)) }

    it { should_not be_able_to(:edit, Factory(:athena_performance, :on_sale => true)) }
    it { should_not be_able_to(:destroy, Factory(:athena_performance, :on_sale => true)) }
  end

end
