class ACH::Transaction
  include ACH::Serialization

  attr_accessor :effective_date, :amount, :check_number, :memo, :secc_type

  def initialize(amount, memo)
    self.amount         = "%0.2f" % (amount / 100.00)
    self.memo           = memo
    self.effective_date = DateTime.now.strftime("%m/%d/%y")
    # TODO: Check number?
    self.check_number   = "Check_No"
    self.secc_type      = "SECCType"
  end

  MAPPING = {
    :type           => "Transaction_Type",
    :effective_date => "Effective_Date",
    :amount         => "Amount_per_Transaction",
    :check_number   => "Check_No",
    :memo           => "Memo",
    :secc_type      => "SECCType",
    :frequency      => "Frequency",
    :count          => "Number_of_Payments"
  }.freeze

  def type
    "Credit"
  end

  def frequency
    "Once"
  end

  def count
    "1"
  end
end