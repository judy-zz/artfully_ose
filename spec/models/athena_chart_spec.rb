require 'spec_helper'

describe AthenaChart do
  subject { Factory(:athena_chart) }

  it { should respond_to :name }
  it { should respond_to :is_template }
  it { should respond_to :event_id }
  it { should respond_to :performance_id }
  it { should respond_to :organization_id }

  describe "#valid?" do
    it { should be_valid }

    it "is not be valid without a name" do
      subject.name = nil
      subject.should_not be_valid

      subject.name = ""
      subject.should_not be_valid
    end
  end

  it "creates a default based on an event" do
    @event = Factory(:event)
    @chart = AthenaChart.default_chart_for(@event)

    @chart.name.should eq AthenaChart.get_default_name(@event.name)
    @chart.event_id.should eq @event.id
    @chart.id.should eq nil
  end

  it "gets charts for an event" do
    @event = Factory(:event)
    FakeWeb.register_uri(:get, "http://localhost/athena/charts.json?eventId=#{@event.id}", :body => "[#{subject.encode}]" )
    @charts = AthenaChart.find_by_event(@event)
    subject.should eq @charts.first
  end

  it "gets charts for an organization" do
    organization = Factory(:organization)
    FakeWeb.register_uri(:get, "http://localhost/athena/charts.json?organizationId=#{organization.id}", :body => "[#{subject.encode}]" )
    @charts = AthenaChart.find_by_organization(organization)
  end

  it "gets templates for an organization" do
    organization = Factory(:organization)
    FakeWeb.register_uri(:get, "http://localhost/athena/charts.json?organizationId=eq#{organization.id}&isTemplate=eqtrue", :body => "[#{subject.encode}]" )
    @charts = AthenaChart.find_templates_by_organization(organization)
  end

  describe "#encode" do
    it "does not include sections in the encoded output" do
      subject.sections = []
      subject.sections << Factory(:athena_section)
      subject.encode.should_not match /"sections":/
    end
  end

  describe ".as_json" do
    it "includes the sections in the output" do
      subject.as_json['sections'].should_not be_empty
    end
  end

  describe "#copy!" do
    before(:each) do
      subject.sections = 2.times.collect { Factory(:athena_section) }
    end

    let(:copy) { subject.copy! }

    it "does not have the same id as the original" do
      copy.id.should_not eq subject.id
    end

    it "has the same name as the original" do
      copy.name.should eq "#{subject.name} (Copy)"
    end

    it "has the same organization" do
      copy.organization_id.should eq subject.organization_id
    end
  end

  describe "#dup!" do
    before(:each) do
      subject.sections = 2.times.collect { Factory(:athena_section) }
    end

    let(:copy) { subject.dup! }

    it "does not have the same id as the original" do
      copy.id.should_not eq subject.id
    end

    it "has the same name as the original" do
      copy.name.should eq subject.name
    end

    it "has the same organization" do
      copy.organization_id.should eq subject.organization_id
    end

    describe "and sections" do
      it "has the same number of sections as the original" do
        copy.sections.size.should eq subject.sections.size
      end

      it "copies each sections name" do
        copy.sections.collect { |section| section.name }.should eq subject.sections.collect { |section| section.name }
      end

      it "copies each sections price" do
        copy.sections.collect { |section| section.price }.should eq subject.sections.collect { |section| section.price }
      end

      it "copies each sections capacity" do
        copy.sections.collect { |section| section.capacity }.should eq subject.sections.collect { |section| section.capacity }
      end
    end
  end

  describe "#assign_to" do
    before :each do
      @event = Factory(:event)
    end

    it "assigns a duplicate chart to the event" do
      FakeWeb.register_uri(:post, "http://localhost/athena/sections.json", :status => 200, :body => Factory(:athena_section_with_id).encode)
      FakeWeb.register_uri(:post, "http://localhost/athena/charts.json", :status => 200, :body => Factory(:athena_chart).encode)
      subject.assign_to(@event)
    end

    it "raises a TypeError if not being assigned to an Event" do
      lambda { subject.assign_to("event") }.should raise_error(TypeError)
    end
  end
end