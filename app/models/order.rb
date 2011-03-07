class Order < ActiveRecord::Base
  include ActiveRecord::Transitions

  has_many :purchasable_tickets, :dependent => :destroy
  has_many :donations, :dependent => :destroy

  after_initialize :clean_order

  state_machine do
    state :started      # The user has added items to their order
    state :approved, :enter => :finish
    state :rejected     # ATHENA has rejected the payment

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

  def add_tickets(line_items)
    line_items = line_items.collect { |i| i.to_item }
    lock_lockables(line_items.select { |i| i.lockable? })
    purchasable_tickets << line_items
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
    options[:settle] = true if options[:settle].nil?

    payment.authorize! ? approve! : reject!
    if options[:settle] and approved?
      payment.settle!
    end
  end

  def finish
    organizations_from_tickets.each do |organization|
      order = AthenaOrder.generate do |order|
        order.for_organization organization
        order.for_items tickets.select { |ticket| AthenaEvent.find(ticket.event_id).organization_id == organization.id }
        order.for_items donations.select { |donations| donation.organization == organization }
      end
      order.save
    end

    OrderMailer.confirmation_for(self).deliver
    purchasable_tickets.map { |ticket| ticket.sold!(person) }
  end

  def generate_donations
    organizations_from_tickets.collect do |organization|
      donation = Donation.new
      donation.organization = organization
      donation
    end
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

    def organizations_from_tickets
      return @organizations unless @organizations.nil?

      events = tickets.collect(&:event_id).uniq.collect! { |id| AthenaEvent.find(id) }
      @organizations = events.collect(&:organization_id).uniq.collect! { |id| Organization.find(id) }
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
