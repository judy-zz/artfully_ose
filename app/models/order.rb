class Order < ActiveRecord::Base
  include ActiveRecord::Transitions

  belongs_to :user
  validates_presence_of :lock_id
  validates_presence_of :tickets

  before_validation :create_lock!
  before_destroy :release_lock!

  validates_each :lock do |model, attr, value|
    model.errors.add(attr, "is invalid") unless (!model.send(attr).nil?) && model.send(attr).valid?
  end


  state_machine do
    state :started      # The Order is associated with a Lock (which may or may not still be valid)
    state :approved     # ATHENA has approved the payment
    state :rejected     # ATHENA has rejected the payment

    event :approve do
      transitions :from => [ :started, :rejected ], :to => :approved
    end

    event :reject do
      transitions :from => :started, :to => :rejected
    end
  end

  def lock
    @lock ||= Athena::Lock.find(lock_id) unless lock_id.nil?
  end

  def lock=(lock)
    raise TypeError, "Expecting an Athena::Lock" unless lock.kind_of? Athena::Lock
    @lock = lock
    self.lock_id = @lock.id
  end

  def tickets
    @tickets ||= proxies_for(lock.tickets)
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
    def create_lock!
      begin
        self.lock = Athena::Lock.create(:tickets => self.tickets.map { |ticket| ticket.id })
      rescue ActiveResource::ResourceConflict
        self.errors.add(:tickets, "could not be locked")
      end if needs_new_lock?
    end

    def needs_new_lock?
      self.lock_id.nil? || !same_tickets?
    end

    def same_tickets?
      self.tickets.map{ |ticket| ticket.id.to_i }.sort == self.lock.tickets.map{ |ticket| ticket.to_i }.sort
    end

    def release_lock!
      begin
        self.lock.destroy unless self.lock.nil?
      rescue ActiveResource::ServerError, ActiveResource::ResourceNotFound
      end
    end

    def proxies_for(ticket_ids)
      ticket_ids.map { |ticket_id| Athena::Proxy::Ticket.new(ticket_id) } || []
    end
end
