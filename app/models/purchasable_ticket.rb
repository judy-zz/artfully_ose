class PurchasableTicket < ActiveRecord::Base
  belongs_to :order
  validates_presence_of :ticket_id

  before_destroy :unlock, :unless => lambda { |p| p.sold? }

  delegate :lockable?, :to => :ticket
  delegate :sold!, :to => :ticket
  delegate :sold?, :to => :ticket

  def price
    ticket.price.to_i
  end

  def ticket
    @ticket ||= AthenaTicket.find(self.ticket_id)
  end

  def ticket=(ticket)
    @ticket, self.ticket_id = ticket, ticket.id
  end

  def lock
    begin
      @lock ||= AthenaLock.find(lock_id) unless lock_id.nil?
    rescue ActiveResource::ResourceNotFound
    end
  end

  def lock=(lock)
    raise TypeError, "Expecting an AthenaLock" unless lock.kind_of? AthenaLock
    @lock, self.lock_id = lock, lock.id
  end

  def unlock
    begin
      lock and lock.destroy
    rescue ActiveResource::ResourceNotFound
    end
  end

  def locked?
    (!!self.lock) and self.lock.valid?
  end

  def item_id
    self.ticket_id
  end

  #TODO: Tech debt here; ticket_id should probably be private and require that ticket always be assigned.
  def ticket_id=(id)
    super(id)
    @ticket = nil
  end
end