class Order < ActiveRecord::Base
  include ActiveRecord::Transitions

  attr_accessor :fee_in_cents

  has_many :purchasable_tickets, :dependent => :destroy
  has_many :donations, :dependent => :destroy

  after_initialize :clean_order, :update_ticket_fee

  state_machine do
    state :started
    state :approved
    state :rejected

    event :approve do
      transitions :from => [ :started, :rejected ], :to => :approved
    end

    event :reject do
      transitions :from => [ :started, :rejected ], :to => :rejected
    end
  end

  def clean_order
    return if approved?
    purchasable_tickets.delete(purchasable_tickets.select{ |item| !item.locked? })
  end

  delegate :empty?, :to => :items
  def items
    self.purchasable_tickets + self.donations
  end

  def tickets
    purchasable_tickets.collect(&:ticket)
  end
  
  def update_ticket_fee
    @fee_in_cents = purchasable_tickets.size * 200
  end

  def add_tickets(tkts)
    ptkts = tkts.collect { |ticket| PurchasableTicket.for(ticket) }
    lock_lockables(ptkts)

    purchasable_tickets << ptkts
  end
  
  def clear_donations
    temp = []
    
    #This won't work if there is more than 1 FAFS donation on the order
    donations.each do |donation|
      temp = donations.delete(donations)
    end
    temp
  end

  def lock_lockables(line_items)
    lock = create_lock(line_items.collect { |i| i.item_id })
    line_items.each do |i|
      i.lock = lock
      i.save
    end
  end

  def total
    items.sum(&:price) + @fee_in_cents
  end

  def unfinished?
    started? or rejected?
  end

  def completed?
    approved?
  end

  def pay_with(payment, options = {})
    @payment = payment

    if payment.requires_authorization?
      pay_with_authorization(payment, options)
    else
      approve!
    end
  end

  def finish(person, order_timestamp)
    purchasable_tickets.each { |ticket| ticket.sell_to(person, order_timestamp) }
  end

  def generate_donations
    organizations_from_tickets.collect do |organization|
      if organization.can?(:receive, Donation)
        donation = Donation.new
        donation.organization = organization
        donation
      end
    end.compact
  end

  def organizations
    (organizations_from_donations + organizations_from_tickets).uniq
  end

  def organizations_from_donations
    donations.collect(&:organization)
  end

  def organizations_from_tickets
    return @organizations unless @organizations.nil?

    events = tickets.collect(&:event_id).uniq.collect! { |id| AthenaEvent.find(id) }
    @organizations = events.collect(&:organization_id).uniq.collect! { |id| Organization.find(id) }
  end

  private

    def pay_with_authorization(payment, options)
      options[:settle] = true if options[:settle].nil?
      payment.authorize! ? approve! : reject!
      payment.settle! if options[:settle] and approved?
    end

    #TODO: Debt: Move this out of order into PurchasableCollection
    def create_lock(ids)
      begin
        lock = AthenaLock.create(:tickets => ids)
      rescue ActiveResource::ResourceConflict
        self.errors.add(:items, "could not be locked")
      end
      lock
    end
end
