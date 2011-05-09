require 'spec_helper'

describe Return do
  let(:order) { Factory(:athena_order_with_id) }
  let(:items) { 3.times.collect { Factory(:athena_item_with_id) } }
  subject { Return.new(order, items) }

  describe "#submit" do
    it "returns each line item" do
      subject.items.each { |item| item.should_receive(:return!) }
      subject.submit
    end
  end

  describe "successful?" do
    it "returns false if it has not been submitted" do
      subject.should_not be_successful
    end

    it "should return true if each return was successful" do
      subject.submit
      subject.should be_successful
    end

    it "returns false if any return was not successful" do
      subject.items.first.stub(:return!).and_return(false)
      subject.submit
      subject.should_not be_successful
    end
  end

end
