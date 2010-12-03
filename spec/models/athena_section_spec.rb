require 'spec_helper'

describe AthenaChart do
  subject { Factory(:athena_section_orchestra) }
  
  it { should be_valid }
  
  it { should respond_to :name }
  it { should respond_to :capacity }
  it { should respond_to :price }
  
  it "can copy itself" do
    @new_section = subject.deep_copy
    
    @new_section.id.should eq nil
    @new_section.name.should eq subject.name
    @new_section.capacity.should eq subject.capacity
    @new_section.price.should eq subject.price
  end
end