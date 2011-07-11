#Used for shopping cart in the widget
class Order < ActiveRecord::Base
  include ActiveRecord::Transitions

  has_many :purchasable_tickets, :dependent => :destroy
  has_many :donations, :dependent => :destroy

  after_initialize :clean_order

  state_machine do
    state :started
    state :approved, :enter => :finish
    state :rejected

    event :approve do
      transitions :from => [ :started, :rejected ], :to => :approved
    end

    event :reject do
      transitions :from => :started, :to => :rejected
    end
  end

  def person
    @person ||= find_person
  end

  def person=(person)
    raise TypeError, "Expecting an AthenaPerson" unless person.kind_of? AthenaPerson
    @person, self.person_id = person, person.id
    save
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

  def add_tickets(tkts)
    ptkts = tkts.collect { |ticket| PurchasableTicket.for(ticket) }
    lock_lockables(ptkts)

    purchasable_tickets << ptkts
  end

  def lock_lockables(line_items)
    lock = create_lock(line_items.collect { |i| i.item_id })
    line_items.each do |i|
      i.lock = lock
      i.save
    end
  end

  def total
    items.inject(0) { |sum, item| sum + item.price }
  end

  def unfinished?
    started? or rejected?
  end

  def completed?
    approved?
  end

  def pay_with(payment, options = {})
    @payment = payment
    options[:settle] = true if options[:settle].nil?

    if payment.amount > 0
      payment.authorize! ? approve! : reject!
      if options[:settle] and approved?
        payment.settle!
      end
    else
      #options[:settle] = true # neccessary?
      payment.transaction_id = nil
      approve!
    end

  end

  def finish
    order_timestamp = Time.now
    purchasable_tickets.map { |ticket| ticket.sell_to(person, order_timestamp) }

    organizations.each do |organization|
      logger.debug("INSIDE organizations.each do |organization|, organization: #{organization}")
      order = AthenaOrder.new.tap do |order|
        order.organization    = organization
        order.timestamp       = order_timestamp
        order.person          = person
        order.transaction_id  = @payment.transaction_id

        #This will break if ActiveResource properly interprets athena_event.organization_id as the integer that it is intended to be
        order << tickets.select { |ticket| AthenaEvent.find(ticket.event_id).organization_id == organization.id.to_s }
        order << donations
      end
      order.save!
    end

    OrderMailer.confirmation_for(self).deliver
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
    #TODO: Debt: Move this out of order into PurchasableCollection
    def create_lock(ids)
      begin
        lock = AthenaLock.create(:tickets => ids)
      rescue ActiveResource::ResourceConflict
        self.errors.add(:items, "could not be locked")
      end
      lock
    end

    def find_person
      return if self.person_id.nil?

      begin
        AthenaCustomer.find(self.person_id)
      rescue ActiveResource::ResourceNotFound
        update_attribute!(:person_id, nil)
        return nil
      end
    end
end
