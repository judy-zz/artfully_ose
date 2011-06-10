class ACH::Account
  include ACH::Serialization

  attr_accessor :routing_number, :number, :type

  MAPPING = {
    :routing_number => "Customer_Bank_ID",
    :number         => "Customer_Bank_Account",
    :type           => "Account_Type"
  }.freeze
end