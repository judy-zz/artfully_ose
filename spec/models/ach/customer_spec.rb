require 'spec_helper'

describe ACH::Customer do
  subject { ACH::Customer.new }

  describe "serializable_hash" do
    it "returns the key-value pairs for the remote attributes and our values" do
      subject.id      = "someCustID"
      subject.name    = "John Doe"
      subject.address = "1234 Main St"
      subject.city    = "Columbia"
      subject.state   = "MD"
      subject.zip     = "21046"
      subject.phone   = "123-789-4568"

      subject.serializable_hash.should <=> {
        "Customer_ID"       => "someCustID",
        "Customer_Name"     => "John Doe",
        "Customer_Address"  => "1234 Main St",
        "Customer_City"     => "Columbia",
        "Customer_State"    => "MD",
        "Customer_Zip"      => "21046",
        "Customer_Phone"    => "123-789-4568"
      }
    end
  end

  describe "#serialize" do
    it "serializes attributes into an HTTP query string" do
      subject.id      = "someCustID"
      subject.name    = "John Doe"
      subject.address = "1234 Main St"
      subject.city    = "Columbia"
      subject.state   = "MD"
      subject.zip     = "21046"
      subject.phone   = "123-789-4568"

      subject.serialize.should == {
        "Customer_ID"       => "someCustID",
        "Customer_Name"     => "John Doe",
        "Customer_Address"  => "1234 Main St",
        "Customer_City"     => "Columbia",
        "Customer_State"    => "MD",
        "Customer_Zip"      => "21046",
        "Customer_Phone"    => "123-789-4568"
      }.to_query
    end
  end
end