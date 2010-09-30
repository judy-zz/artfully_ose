require File.dirname(__FILE__) + '/../spec_helper'

describe Schema, "The Schema class" do
  before(:each) do
    FakeWeb.allow_net_connect = false

    @schema = Factory.build(:schema)
    FakeWeb.register_uri(:get, "http://localhost/tickets/fields", :body => "{}")
  end

  it "should require a default base URI" do
    Schema.base_uri.should_not be_nil
  end

  it "should allow the base URI to be changed" do
    Schema.base_uri = 'http://www.example.com'
    Schema.base_uri.should == 'http://www.example.com'
  end

  it "should create a new Schema given information for a specified resource" do
    FakeWeb.register_uri(:get, "#{Schema.base_uri}/test/fields", body => "{}")
    @schema = Schema.find(:test)
    @schema.should be_valid
  end

  it "should store schema fields as attributes" do
    @schema = Factory.build(:schema, :resource => :test)
    FakeWeb.register_uri(:get, "#{Schema.base_uri}/#{@schema.resource}/fields", body => "{}")
    @new_schema = Schema.find(:test)
    @new_schema.should be_valid
    @new_schema.resource == :test
  end
end
