require 'spec_helper'

describe Ability do
  describe "Producers with free ticketing" do
    let(:user) { Factory(:user) }
    let(:organization) { Factory(:organization) }

    subject do
      user.organizations << organization
      Ability.new(user)
    end

    #this is for events_controller.new, not .create
    describe "who are creating an event" do
      it { should be_able_to(:new, Event) }
    end

    describe "and are creating tickets with priced sections" do
      sections = Array.new
      sections << Factory(:athena_section)
      it { should_not be_able_to(:create_tickets, sections) }
    end

    describe "and are creating tickets with free sections" do
      sections = Array.new
      sections << Factory(:athena_free_section)
      it { should be_able_to(:create_tickets, sections) }
    end
  end

  describe "Producers who have upgraded to paid ticketing" do
    let(:user) { Factory(:user) }
    let(:organization) { Factory(:organization_with_ticketing) }

    subject do
      user.organizations << organization
      Ability.new(user)
    end

    describe "and events" do
      it { should be_able_to(:manage, Factory(:event, :organization_id => organization.id)) }
      it { should be_able_to(:create, Event) }

      it { should_not be_able_to(:manage, Factory(:event, :organization_id => organization.id + 1)) }

      it "should not be able to delete an event where the performances cannot be deleted also" do
        performances = 3.times.collect { mock(:performance, :live? => true) }
        event = Factory(:event, :organization_id => organization.id, :performances => performances)
        subject.should_not be_able_to(:destroy, event)
      end
    end

    describe "and performances" do
      it { should be_able_to(:manage, Factory(:show, :organization_id => organization.id)) }
      it { should be_able_to(:create, Show) }

      it { should_not be_able_to(:manage, Factory(:show, :organization_id => organization.id + 1)) }

      it { should_not be_able_to(:edit, Factory(:show, :state => "on_sale")) }
      it { should_not be_able_to(:destroy, Factory(:show, :state => "on_sale")) }
      it { should_not be_able_to(:destroy, Factory(:show, :state => "built")) }
    end

    describe "and charts" do
      let(:chart) { Factory(:athena_chart, :organization_id => organization.id) }

      it { should be_able_to :view, chart }
      it { should be_able_to :manage, chart }
      it { should_not be_able_to(:manage, Factory(:athena_chart, :organization_id => organization.id + 1)) }
      it { should_not be_able_to(:view, Factory(:athena_chart, :organization_id => organization.id + 1)) }
    end

    describe "and tickets" do
      let(:event) { Factory(:event, :organization_id => organization.id) }

      it { should be_able_to(:manage, Factory(:ticket_with_id, :event_id => event.id)) }
      it { should be_able_to(:manage, AthenaTicket) }
      it { should be_able_to(:bulk_edit, AthenaTicket) }
    end
  end

  describe "Producers who are not in an organization" do
    let(:user) { Factory(:user) }
    subject { Ability.new(user) }

    describe "working with events" do
      it { should_not be_able_to :create, Event }
      it { should_not be_able_to :edit, Event }
      it { should_not be_able_to :delete, Event }
    end

    describe "working with performances" do
      it { should_not be_able_to :create, Show }
      it { should_not be_able_to :edit, Show }
      it { should_not be_able_to :delete, Show }
    end

    describe "working with charts" do
      it { should_not be_able_to :create, AthenaChart }
      it { should_not be_able_to :edit, AthenaChart }
      it { should_not be_able_to :delete, AthenaChart }
    end
  end
end
