class ACH::Request
  include HTTParty
  base_uri ACH::CONFIG['base_uri']

  CREDENTIALS = {
    "Login_ID"        => ACH::CONFIG['login_id'],
    "Transaction_Key" => ACH::CONFIG['transaction_key'],
  }.freeze

  attr_reader :transaction, :customer, :account

  def self.for(amount, recipient)
    transaction = ACH::Transaction.new(amount, "Some Memo")
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
    self.class.get("/https/TransRequest.asp", :query => query)
  end

  private

  def all_hashes
    [ transaction, customer, account ].collect(&:serializable_hash).reduce(:merge)
  end
end