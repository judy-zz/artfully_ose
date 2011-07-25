require 'spec_helper'

describe AthenaChart do
  subject { Factory(:athena_section) }

  it { should be_valid }

  it { should respond_to :name }
  it { should respond_to :capacity }
  it { should respond_to :price }
  it { should respond_to :chart_id }

  describe "valid?" do
    it "should not be valid without a name" do
      subject.name = nil
      subject.should_not be_valid
    end

    it "should not be valid without a capacity" do
      subject.capacity = nil
      subject.should_not be_valid
    end

    it "should not be valid without a numerical capacity" do
      subject.capacity = "some cap"
      subject.should_not be_valid
    end

    it "should not be valid without price" do
      subject.price = nil
      subject.should_not be_valid
    end

    it "should not be valid without a numerical price" do
      subject.capacity = "some price"
      subject.should_not be_valid
    end

    it "is not valid with a capacity over 1000" do
      subject.capacity = 1001
      subject.should_not be_valid
    end
  end

  describe "#dup!" do
    let(:copy){ subject.dup! }

    it "should not have the same id" do
      subject.id = 1
      copy.id.should_not eq subject.id
    end

    it "should have the same name" do
      copy.name.should eq subject.name
    end

    it "should have the same capacity" do
      copy.capacity.should eq subject.capacity
    end

    it "should have the same price" do
      copy.price.should eq subject.price
    end
  end
end