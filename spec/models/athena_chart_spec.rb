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
  
  it "can copy itself and its sections" do    
    @orchestra_section = Factory(:athena_section_orchestra)
    @balcony_section = Factory(:athena_section_balcony)
    
    subject.sections = [@orchestra_section, @balcony_section]
    subject.sections.each do |section|
      section.chart_id = subject.id
    end
    
    @new_chart = subject.deep_copy
    
    @new_chart.sections.size.should eq subject.sections.size
    @new_chart.sections[0].id.should eq nil
    @new_chart.sections[0].name.should eq @orchestra_section.name
    @new_chart.sections[0].capacity.should eq @orchestra_section.capacity
    @new_chart.sections[0].price.should eq @orchestra_section.price
    @new_chart.sections[1].id.should eq nil
    @new_chart.sections[1].name.should eq @balcony_section.name
    @new_chart.sections[1].capacity.should eq @balcony_section.capacity
    @new_chart.sections[1].price.should eq @balcony_section.price
  end
end