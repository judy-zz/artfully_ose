require 'spec_helper'

describe AthenaChart do
  subject { Factory(:athena_chart) }

  it { should be_valid }

  it { should respond_to :name }
  it { should respond_to :sections }
  it { should respond_to :producer_pid }

  it "should create a default based on an event" do
    @event = Factory(:athena_event)
    @chart = AthenaChart.default_chart_for(@event)

    @chart.name.should eq AthenaChart.get_default_name(@event.name)
    @chart.event_id.should eq @event.id
    @chart.id.should eq nil
  end

  describe "#dup!" do
    before(:each) do
      @original = Factory(:athena_chart)
      @orchestra_section = Factory(:athena_section_orchestra)
      @balcony_section = Factory(:athena_section_balcony)
      @original.sections = [@balcony_section, @orchestra_section]
      @copy = @original.dup!
    end

    it "should not have the same id as the original" do
      @copy.id.should_not eq @original.id
    end

    it "should have the same name as the original" do
      @copy.name.should eq @original.name
    end

    it "should have the same producer pid" do
      @copy.producer_pid.should eq @original.producer_pid
    end

    describe "and sections" do
      it "should have the same number of sections as the original" do
        @copy.sections.size.should eq @original.sections.size
      end

      it "should copy each sections name" do
        @copy.sections.collect { |section| section.name }.should eq @original.sections.collect { |section| section.name }
      end

      it "should copy each sections price" do
        @copy.sections.collect { |section| section.price }.should eq @original.sections.collect { |section| section.price }
      end

      it "should copy each sections capacity" do
        @copy.sections.collect { |section| section.capacity }.should eq @original.sections.collect { |section| section.capacity }
      end
    end
  end
end