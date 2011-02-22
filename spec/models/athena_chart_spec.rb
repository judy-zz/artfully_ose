require 'spec_helper'

describe AthenaChart do
  subject { Factory(:athena_chart) }

  it { should be_valid }

  it { should respond_to :name }
  it { should respond_to :sections }
  it { should respond_to :organization_id }
  it { should respond_to :is_template }

  it "should not be valid without a name" do
    subject.name = nil
    subject.should_not be_valid

    subject.name = ""
    subject.should_not be_valid
  end


  it "should create a default based on an event" do
    @event = Factory(:athena_event)
    @chart = AthenaChart.default_chart_for(@event)

    @chart.name.should eq AthenaChart.get_default_name(@event.name)
    @chart.event_id.should eq @event.id
    @chart.id.should eq nil
  end

  it "should get charts for an event" do
    @event = Factory(:athena_event_with_id)
    FakeWeb.register_uri(:get, "http://localhost/stage/charts/.json?eventId=eq#{@event.id}", :body => "[#{subject.encode}]" )
    @charts = AthenaChart.find_by_event(@event)
    subject.should eq @charts.first
  end

  it "should get charts for an organization" do
    organization = Factory(:organization)
    FakeWeb.register_uri(:get, "http://localhost/stage/charts/.json?organizationId=eq#{organization.id}", :body => "[#{subject.encode}]" )
    @charts = AthenaChart.find_by_organization(organization)
  end

  it "should get templates for an organization" do
    organization = Factory(:organization)
    FakeWeb.register_uri(:get, "http://localhost/stage/charts/.json?organizationId=eq#{organization.id}&isTemplate=eqtrue", :body => "[#{subject.encode}]" )
    @charts = AthenaChart.find_templates_by_organization(organization)
  end

  describe "sections" do
    it "should not include sections in the encoded output" do
      subject.sections = []
      subject.sections << Factory(:athena_section)
      subject.encode.should_not match /"sections":/
    end
  end

  describe "#dup!" do
    before(:each) do
      subject.sections = 2.times.collect { Factory(:athena_section) }
      @copy = subject.dup!
    end

    it "should not have the same id as the original" do
      @copy.id.should_not eq subject.id
    end

    it "should have the same name as the original" do
      @copy.name.should eq subject.name
    end

    it "should have the same organization" do
      @copy.organization_id.should eq subject.organization_id
    end

    describe "and sections" do
      it "should have the same number of sections as the original" do
        @copy.sections.size.should eq subject.sections.size
      end

      it "should copy each sections name" do
        @copy.sections.collect { |section| section.name }.should eq subject.sections.collect { |section| section.name }
      end

      it "should copy each sections price" do
        @copy.sections.collect { |section| section.price }.should eq subject.sections.collect { |section| section.price }
      end

      it "should copy each sections capacity" do
        @copy.sections.collect { |section| section.capacity }.should eq subject.sections.collect { |section| section.capacity }
      end
    end
  end
  describe "#assign_to" do
    before :each do
      @event = Factory(:athena_event)
    end

    it "should assign a duplicate chart to the event" do
      FakeWeb.register_uri(:post, "http://localhost/stage/sections/.json", :status => 200, :body => Factory(:athena_section_with_id).encode)
      FakeWeb.register_uri(:post, "http://localhost/stage/charts/.json", :status => 200, :body => Factory(:athena_chart).encode)
      subject.assign_to(@event)
    end

    it "should raise a TypeError if not being assigned to an AthenaEvent" do
      lambda { subject.assign_to("event") }.should raise_error(TypeError)
    end
  end
end