require 'spec_helper'

describe Chart do
  subject { Factory(:chart) }

  it { should respond_to :name }
  it { should respond_to :is_template }
  it { should respond_to :event_id }
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

  it "should always order sections by price descending" do
    @chart = Factory(:chart)
    @chart.name = 'Chartie'
    @chart.sections << Section.new({:price => 30, :name => 'one', :capacity => 30})
    @chart.sections << Section.new({:price => 40, :name => 'two', :capacity => 30})
    @chart.sections << Section.new({:price => 25, :name => 'three', :capacity => 30})
    @chart.save
    sections = @chart.sections
    sections[0].price.should eq 40
  end

  it "creates a default based on an event" do
    @event = Factory(:event)
    @chart = Chart.default_chart_for(@event)

    @chart.name.should eq Chart.get_default_name(@event.name)
    @chart.event_id.should eq @event.id
    @chart.id.should eq nil
  end

  describe "#as_json" do
    it "includes the sections in the output" do
      subject.sections << Factory(:section)
      subject.as_json['sections'].should_not be_empty
    end
  end

  describe "#copy!" do
    before(:each) do
      subject.sections = 2.times.collect { Factory(:section) }
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
      subject.sections = 2.times.collect { Factory(:section) }
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
    pending
  end
end