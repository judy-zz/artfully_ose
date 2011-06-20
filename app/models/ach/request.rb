module ACH
  class Request
    include HTTParty
    base_uri ACH::CONFIG['base_uri']

    require 'ach/exceptions'

    CREDENTIALS = {
      "Login_ID"        => ACH::CONFIG['login_id'],
      "Transaction_Key" => ACH::CONFIG['transaction_key'],
    }.freeze

    attr_reader :transaction, :customer, :account

    def self.for(amount, recipient, memo)
      transaction = ACH::Transaction.new(amount, memo)
      customer    = ACH::Customer.new(recipient.customer_information)
      account     = ACH::Account.new(recipient.account_information)
      new(transaction, customer, account)
    end

    def initialize(transaction, customer, account)
      @transaction = transaction
      @customer = customer
      @account = account
      super()
    end

    def query
      CREDENTIALS.merge(all_hashes)
    end

    def submit
      response = self.class.get("/https/TransRequest.asp", :query => query)

      case response.body
      when /^10\d{7}/
        response.body.gsub(/^10/, "")
      when "02"
        raise ACH::BadRequest.new(response.body)
      when "03"
        raise ACH::MissingData.new(response.body)
      when /^(0[4-9]|1[1-4])/
        raise ACH::InvalidRequest.new(response.body)
      when "10"
        raise ACH::DuplicateRequest.new(response.body)
      else
        raise ACH::ClientError.new(response.body)
      end
    end

    private

    def all_hashes
      [ transaction, customer, account ].collect(&:serializable_hash).reduce(:merge)
    end
  end
end