class Order < ActiveRecord::Base
  include ActiveRecord::Transitions

  belongs_to :user
  validates_presence_of :transaction_id
  validates_presence_of :tickets

  before_validation :create_transaction!
  before_destroy :release_transaction!

  validates_each :transaction do |model, attr, value|
    model.errors.add(attr, "is invalid") unless (!model.send(attr).nil?) && model.send(attr).valid?
  end


  state_machine do
    state :started      # The Order is associated with a Transaction (which may or may not still be valid)
    state :approved     # ATHENA has approved the payment
    state :rejected     # ATHENA has rejected the payment

    event :approve do
      transitions :from => [ :started, :rejected ], :to => :approved
    end

    event :reject do
      transitions :from => :started, :to => :rejected
    end
  end

  def transaction
    @transaction ||= Athena::Transaction.find(transaction_id) unless transaction_id.nil?
  end

  def transaction=(transaction)
    raise TypeError, "Expecting a Transaction" unless transaction.kind_of? Athena::Transaction
    @transaction = transaction
    self.transaction_id = @transaction.id
  end

  def tickets
    @tickets ||= proxies_for(transaction.tickets)
  end

  def tickets=(tickets)
    @tickets = proxies_for(tickets)
  end

  def total
    self.tickets.inject(0) { |sum, ticket| sum + ticket.price.to_i }
  end

  def unfinished?
    started? or rejected?
  end

  def pay_with(payment, options = {})
    options[:settle] = true if options[:settle].nil?

    payment.authorize! ? approve! : reject!
    if options[:settle] and approved?
      payment.settle!
    end
  end

  private
    def create_transaction!
      begin
        self.transaction = Athena::Transaction.create(:tickets => self.tickets.map { |ticket| ticket.id })
      rescue ActiveResource::ResourceConflict
        self.errors.add(:tickets, "could not be locked")
      end if needs_new_transaction?
    end

    def needs_new_transaction?
      self.transaction_id.nil? || !same_tickets?
    end

    def same_tickets?
      self.tickets.map{ |ticket| ticket.id.to_i }.sort == self.transaction.tickets.map{ |ticket| ticket.to_i }.sort
    end

    def release_transaction!
      begin
        self.transaction.destroy unless self.transaction.nil?
      rescue ActiveResource::ServerError, ActiveResource::ResourceNotFound
      end
    end

    def proxies_for(ticket_ids)
      ticket_ids.map { |ticket_id| Athena::Proxy::Ticket.new(ticket_id) } || []
    end
end
