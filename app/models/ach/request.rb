class ACH::Request
  attr_reader :transaction, :customer, :account

  def initialize(transaction, customer, account)
    @transaction = transaction
    @customer = customer
    @account = account
  end

  def serialize
    all_hashes.collect { |key, value| "#{key}=#{value}" }.join("&")
  end

  private

  def all_hashes
    [ transaction, customer, account ].collect(&:serializable_hash).reduce(:merge)
  end

end