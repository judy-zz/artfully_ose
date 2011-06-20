# 01xxxxxxx Transaction request successful where x = Transaction ID
# 02 Incorrect number of name-value pairs supplied
# 03 Missing Data
# 04 Invalid SECCType
# 05 Invalid Account_Type
# 06 Invalid Customer_Bank_ID
# 07 Invalid Transaction_Type
# 08 Invalid Number_of_Payments
# 09 Invalid Amount_per_Transaction
# 10 AP DUP (Approved Duplicate) indicates that duplicate filtering is enabled for the merchant account and the transaction request submitted is a duplicate of an existing transaction. Requests with a response of AP DUP will not be processed.
# 11 Invalid Login_ID or Transaction_Key
# 12 Invalid Frequency
# 13 Invalid Customer_Bank_Account

module ACH
  class ClientError < StandardError
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def to_s
      @response
    end
  end

  class BadRequest < ClientError
    def to_s
      "#{@response} Incorrect number of name-value pairs supplied"
    end
  end

  class MissingData < ClientError
  end

  class InvalidRequest < ClientError
  end

  class DuplicateRequest < ClientError
  end
end