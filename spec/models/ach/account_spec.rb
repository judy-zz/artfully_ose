require 'spec_helper'

describe ACH::Account do
  subject { ACH::Account.new }

  describe "serializable_hash" do
    it "returns the key-value pairs for the remote attributes and our values" do
      subject.routing_number  = "111111118"
      subject.number          = "3215240125"
      subject.type            = "Business Checking"

      subject.serializable_hash.should <=> {
        "Customer_Bank_ID"      => "111111118",
        "Customer_Bank_Account" => "3215240125",
        "Account_Type"          => "Business Checking"
      }
    end
  end

  describe "#serialize" do
    it "serializes attributes into an HTTP query string" do
      subject.routing_number  = "111111118"
      subject.number          = "3215240125"
      subject.type            = "Business Checking"

      subject.serialize.should == {
        "Customer_Bank_ID"      => "111111118",
        "Customer_Bank_Account" => "3215240125",
        "Account_Type"          => "Business Checking"
      }.to_query
    end
  end
end