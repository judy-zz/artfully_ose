require 'spec_helper'

describe AthenaItem do

  subject { Factory(:athena_item) }

  %w( order_id item_type item_id price ).each do |attribute|
    it { should respond_to attribute }
    it { should respond_to attribute + "=" }
  end

  describe "order" do
    it "should fetch the order form the remote" do
      subject.order.should be_an AthenaOrder
      subject.order.id.should eq subject.order_id
    end

    it "should return nil if the order_id is not set" do
      subject.order = subject.order_id = nil
      subject.order.should be_nil
    end
  end

  describe "refund_item" do
    it "should create a duplicate item without the id" do
      old_attr = subject.attributes.dup
      old_attr.delete(:id)

      new_attr = subject.refund_item.attributes
      new_attr.delete(:state)

      old_attr.should eq new_attr
    end
  end
end
