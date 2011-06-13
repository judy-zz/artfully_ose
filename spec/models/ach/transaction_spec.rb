require 'spec_helper'

describe ACH::Transaction do
  let(:amount) { 2500 }
  let(:memo) { "Test Settlement" }
  subject { ACH::Transaction.new(amount, memo) }

  describe ".new" do
    it "sets the amount to dollars as a string" do
      subject.amount.should eq "25.00"
    end

    it "sets the effective date to today" do
      subject.effective_date.should eq DateTime.now.strftime("%m/%d/%y")
    end

    it "sets the memo" do
      subject.memo.should eq memo
    end
  end

  describe "serializable_hash" do
    it "returns the key-value pairs for the remote attributes and our values" do
      subject.effective_date = "01/01/2010"
      subject.amount         = "1.23"
      subject.check_number   = "8714"
      subject.memo           = "Memo!"
      subject.secc_type      = "CCD"

      subject.serializable_hash.should <=> {
        "Transaction_Type"        => "Credit",
        "Effective_Date"          => "01/01/2010",
        "Amount_per_Transaction"  => "1.23",
        "Check_No"                => "8714",
        "Memo"                    => "Memo!",
        "Frequency"               => "Once",
        "Number_of_Payments"      => "1",
        "SECCType"                => "CCD"
      }
    end
  end

  describe "#serialize" do
    it "serializes attributes into an HTTP query string" do
      subject.effective_date = "01/01/2010"
      subject.amount         = "1.23"
      subject.check_number   = "8714"
      subject.memo           = "Memo!"
      subject.secc_type      = "CCD"

      subject.serialize.should == {
        "Transaction_Type"        => "Credit",
        "Effective_Date"          => "01/01/2010",
        "Amount_per_Transaction"  => "1.23",
        "Check_No"                => "8714",
        "Memo"                    => "Memo!",
        "Frequency"               => "Once",
        "Number_of_Payments"      => "1",
        "SECCType"                => "CCD"
      }.to_query
    end
  end
end