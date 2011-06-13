class ACH::Request < ActiveResource::Base
  self.site = "https://demo.firstach.com/https/TransRequest.asp"

  CREDENTIALS = {
    "Login_ID"        => :loginid,
    "Transaction_Key" => :somekey,
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

  def serialize
    CREDENTIALS.merge(all_hashes).to_query
  end

  def submit
    path = "#{self.class.site}?#{self.serialize}"
    connection.get(path, self.class.headers)
  end

  private

  def all_hashes
    [ transaction, customer, account ].collect(&:serializable_hash).reduce(:merge)
  end
end