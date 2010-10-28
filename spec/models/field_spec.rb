require 'spec_helper'

describe Field do
  before(:each) do
    Field.site = 'http://localhost'
  end

  it "should have a schema that matches ATHENA" do
    Field.schema.should include(:id)
    Field.schema.should include(:name)
    Field.schema.should include(:strict)
    Field.schema.should include(:valueType)
  end

  it "should fetch the Ticket schema from ATHENA" do
    fake_field = Factory(:field)
    FakeWeb.register_uri(:get, "http://localhost/tickets/fields/.json", :body => "[#{fake_field.attributes.to_json}]")

    fields = Field.find(:all)
    fields.first.should == fake_field
  end
end
