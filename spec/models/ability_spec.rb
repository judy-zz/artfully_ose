require 'spec_helper'

describe Ability do
  describe "Admins" do
    let(:user) { Factory(:admin) }
    subject { Ability.new(user) }

    it { should be_able_to(:administer, :all) }
  end

  describe "users in an organization with access to ticketing" do
    let(:user) { Factory(:user) }
    let(:organization) { Factory(:organization_with_ticketing) }

    subject do
      user.organizations << organization
      Ability.new(user)
    end

    describe "and events" do
      it { should be_able_to(:manage, Factory(:athena_event, :organization_id => organization.id)) }
      it { should be_able_to(:create, AthenaEvent) }

      it { should_not be_able_to(:manage, Factory(:athena_event, :organization_id => organization.id + 1)) }

      it "should not be able to delete an event where the performances cannot be deleted also" do
        performances = 3.times.collect { Factory(:athena_performance, :organization_id => organization.id, :state => "built") }
        event = Factory(:athena_event, :organization_id => organization.id, :performances => performances)
        subject.should_not be_able_to(:destroy, event)
      end
    end

    describe "and performances" do
      it { should be_able_to(:manage, Factory(:athena_performance, :organization_id => organization.id)) }
      it { should be_able_to(:create, AthenaPerformance) }

      it { should_not be_able_to(:manage, Factory(:athena_performance, :organization_id => organization.id + 1)) }

      it { should_not be_able_to(:edit, Factory(:athena_performance, :state => "on_sale")) }
      it { should_not be_able_to(:destroy, Factory(:athena_performance, :state => "on_sale")) }
      it { should_not be_able_to(:destroy, Factory(:athena_performance, :state => "built")) }
    end

    describe "and charts" do
      let(:chart) { Factory(:athena_chart, :organization_id => organization.id) }

      it { should be_able_to :view, chart }
      it { should be_able_to :manage, chart }
      it { should_not be_able_to(:manage, Factory(:athena_chart, :organization_id => organization.id + 1)) }
      it { should_not be_able_to(:view, Factory(:athena_chart, :organization_id => organization.id + 1)) }
    end

    describe "and tickets" do
      let(:event) { Factory(:athena_event_with_id, :organization_id => organization.id) }

      it { should be_able_to(:manage, Factory(:ticket_with_id, :event_id => event.id)) }
      it { should be_able_to(:manage, AthenaTicket) }
      it { should be_able_to(:bulk_edit, AthenaTicket) }
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
