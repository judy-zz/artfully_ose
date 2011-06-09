require 'spec_helper'

describe ACH::Transaction do
  subject { ACH::Transaction.new }

  describe "#serialize" do
    it "serializes attributes into an HTTP query string" do
      subject.login_id       = "eFco0UJyK8Tm"
      subject.key            = "7002b9ca57d92a41"
      subject.type           = "Debit"
      subject.effective_date = "01/01/2010"
      subject.amount         = "1.23"
      subject.check_number   = "8714"
      subject.memo           = "Memo!"
      subject.secc_type      = "CCD"

      subject.serialize.should == "Login_ID=eFco0UJyK8Tm&Transaction_Key=7002b9ca57d92a41&Transaction_Type=Debit&Effective_Date=01/01/2010&Amount_per_Transaction=1.23&Check_No=8714&Memo=Memo!&SECCType=CCD&Frequency=Once&Number_of_Payments=1"
    end
  end
end