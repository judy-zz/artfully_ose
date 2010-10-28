class Order < ActiveRecord::Base
  include ActiveRecord::Transitions

  belongs_to :user

  state_machine do
    state :started
    state :submitted
    state :confirmed
    state :approved
    state :rejected
    state :finished
  end

  def transaction
    @transaction ||= Transaction.find(transaction_id)
  end

  def transaction=(transaction)
    raise TypeError, "Expecting a Transaction" unless transaction.kind_of? Transaction
    @transaction = transaction
    update_attribute(:transaction_id, @transaction.id)
  end

  def tickets
    @tickets ||= proxies_for(transaction.tickets)
  end

  private
    def proxies_for(ticket_ids)
      proxies = []
      ticket_ids.each do |ticket_id|
        proxies << TicketProxy.new(ticket_id)
      end
      proxies
    end
end
