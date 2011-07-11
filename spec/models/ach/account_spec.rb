require 'spec_helper'

describe ACH::Account do
  subject { Factory(:ach_account) }

  let(:hsh) {
    {
      "Customer_Bank_ID"      => "111111118",
      "Customer_Bank_Account" => "3215240125",
      "Account_Type"          => "Business Checking"
    }
  }
  describe "serializable_hash" do
    it "returns the key-value pairs for the remote attributes and our values" do
      subject.routing_number  = "111111118"
      subject.number          = "3215240125"
      subject.type            = "Business Checking"

      subject.serializable_hash.should eq hsh
    end
  end

  describe "#serialize" do
    it "serializes attributes into an HTTP query string" do
      subject.routing_number  = "111111118"
      subject.number          = "3215240125"
      subject.type            = "Business Checking"

      subject.serialize.should eq hsh.to_query
    end
  end
end