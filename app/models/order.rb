class Order < ActiveRecord::Base
  include ActiveRecord::Transitions

  belongs_to :user

  validates_presence_of :transaction_id

  validates_each :transaction do |model, attr, value|
    model.errors.add(attr, "is invalid") unless model.send(attr).valid?
  end


  state_machine do
    state :started
    state :submitted
    state :confirmed
    state :approved
    state :rejected
    state :finished
  end

  def transaction
    @transaction ||= Transaction.find(transaction_id) unless transaction_id.nil?
  end

  def transaction=(transaction)
    raise TypeError, "Expecting a Transaction" unless transaction.kind_of? Transaction
    @transaction = transaction
    update_attribute(:transaction_id, @transaction.id)
  end

  def tickets
    @tickets ||= proxies_for(transaction.tickets)
  end

  def tickets=(tickets)
    release_transaction!
    unless tickets.empty?
      self.transaction = Transaction.create(:tickets => tickets)
      @tickets = proxies_for(tickets)
    end
  end

  private
    def release_transaction!
      Transaction.delete(self.transaction_id) unless self.transaction_id.nil?
    end

    def proxies_for(ticket_ids)
      ticket_ids.map { |ticket_id| TicketProxy.new(ticket_id) }
    end
end
