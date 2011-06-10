class ACH::Transaction
  include ACH::Serialization

  attr_accessor :login_id, :key, :type, :effective_date, :amount, :check_number, :memo, :secc_type

  MAPPING = {
    :login_id       => "Login_ID",
    :key            => "Transaction_Key",
    :type           => "Transaction_Type",
    :effective_date => "Effective_Date",
    :amount         => "Amount_per_Transaction",
    :check_number   => "Check_No",
    :memo           => "Memo",
    :secc_type      => "SECCType",
    :frequency      => "Frequency",
    :count          => "Number_of_Payments"
  }.freeze

  def frequency
    "Once"
  end

  def count
    "1"
  end
end