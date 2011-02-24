class Order < ActiveRecord::Base
  include ActiveRecord::Transitions

  belongs_to :user

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
    OrderMailer.confirmation_for(self).deliver
    purchasable_tickets.map { |ticket| ticket.sold!(user.person) }
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
      events = tickets.collect(&:event_id).uniq.collect! { |id| AthenaEvent.find(id) }
      producers = events.collect(&:organization_id).uniq.collect! { |id| Organization.find(id) }
    end
end
