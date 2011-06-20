module ACH
  class Account
    include ACH::Serialization

    attr_accessor :routing_number, :number, :type

    def initialize(attributes = {})
      self.routing_number = attributes[:routing_number]
      self.number         = attributes[:number]
      self.type           = attributes[:account_type]
    end

    MAPPING = {
      :routing_number => "Customer_Bank_ID",
      :number         => "Customer_Bank_Account",
      :type           => "Account_Type"
    }.freeze
  end
end