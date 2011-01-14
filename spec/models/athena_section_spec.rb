require 'spec_helper'

describe AthenaChart do
  subject { Factory(:athena_section) }

  it { should be_valid }

  it { should respond_to :name }
  it { should respond_to :capacity }
  it { should respond_to :price }
  it { should respond_to :chart_id }

  describe "#dup!" do
    before(:each) do
      @copy = subject.dup!
    end

    it "should not have the same id" do
      subject.id = 1
      @copy.id.should_not eq subject.id
    end

    it "should have the same name" do
      @copy.name.should eq subject.name
    end

    it "should have the same capacity" do
      @copy.capacity.should eq subject.capacity
    end

    it "should have the same price" do
      @copy.price.should eq subject.price
    end
  end
end