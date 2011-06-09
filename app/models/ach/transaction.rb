class ACH::Transaction
  attr_accessor :login_id, :key, :type, :effective_date, :amount, :check_number, :memo, :secc_type

  MAPPING = {
    :login_id       => "Login_ID",
    :key            => "Transaction_Key",
    :type           => "Transaction_Type",
    :effective_date => "Effective_Date",
    :amount         => "Amount_per_Transaction",
    :check_number   => "Check_No",
    :memo           => "Memo",
    :secc_type      => "SECCType"
  }.freeze

  def serialize
    (MAPPING.collect{ |method, key| "#{key}=#{send(method)}" } + constant_parameters).join("&")
  end

  def constant_parameters
    [ "Frequency=Once", "Number_of_Payments=1" ]
  end
end