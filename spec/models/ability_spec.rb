require 'spec_helper'

describe Ability do
  describe "Admins" do
  end

  describe "Producers" do
    let(:user) { Factory(:producer) }
    subject { Ability.new(user) }

    describe "and events" do
      it { should be_able_to(:manage, Factory(:athena_event, :producer_pid => user.athena_id)) }
      it { should be_able_to(:create, AthenaEvent) }

      it { should_not be_able_to(:manage, Factory(:athena_event, :producer_pid => user.athena_id + 1)) }

      it "should not be able to delete an event where the performances cannot be deleted also" do
        performances = 3.times.collect { Factory(:athena_performance, :producer_pid => user.athena_id, :on_sale => true) }
        event = Factory(:athena_event, :producer_pid => user.athena_id, :performances => performances)
        subject.should_not be_able_to(:destroy, event)
      end
    end

    describe "and performances" do
      it { should be_able_to(:manage, Factory(:athena_performance, :producer_pid => user.athena_id)) }
      it { should be_able_to(:create, AthenaPerformance) }

      it { should_not be_able_to(:manage, Factory(:athena_performance, :producer_pid => user.athena_id + 1)) }

      it { should_not be_able_to(:edit, Factory(:athena_performance, :on_sale => true)) }
      it { should_not be_able_to(:destroy, Factory(:athena_performance, :on_sale => true)) }
      it { should_not be_able_to(:destroy, Factory(:athena_performance, :tickets_created => true)) }
    end

    describe "and tickets" do
      it { should be_able_to(:bulk_edit, :tickets) }
    end
  end

  describe "Patrons" do
    let(:user) { Factory(:user) }
    subject { Ability.new(user) }

    describe "and events" do
      it { should_not be_able_to :create, AthenaEvent }
      it { should_not be_able_to :edit, AthenaEvent }
      it { should_not be_able_to :delete, AthenaEvent }
    end

    describe "and performances" do
      it { should_not be_able_to :create, AthenaPerformance }
      it { should_not be_able_to :edit, AthenaPerformance }
      it { should_not be_able_to :delete, AthenaPerformance }
    end

    describe "and charts" do
      it { should_not be_able_to :create, AthenaChart }
      it { should_not be_able_to :edit, AthenaChart }
      it { should_not be_able_to :delete, AthenaChart }
    end
  end
end
