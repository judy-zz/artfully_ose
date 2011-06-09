class ACH::Account
  attr_accessor :routing_number, :number, :type

  MAPPING = {
    :routing_number => "Customer_Bank_ID",
    :number         => "Customer_Bank_Account",
    :type           => "Account_Type"
  }.freeze

  def serialize
    MAPPING.collect{ |method, key| "#{key}=#{send(method)}" }.join("&")
  end
end