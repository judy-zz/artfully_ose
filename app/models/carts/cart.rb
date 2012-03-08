class Cart < ActiveRecord::Base
  include ActiveRecord::Transitions

  has_many :donations, :dependent => :destroy
  has_many :tickets, :after_add => :set_timeout
  after_destroy :release_tickets
  attr_accessor :special_instructions

  state_machine do
    state :started
    state :approved
    state :rejected

    event(:approve) { transitions :from => [ :started, :rejected ], :to => :approved }
    event(:reject)  { transitions :from => [ :started, :rejected ], :to => :rejected }
  end

  delegate :empty?, :to => :items
  def items
    self.tickets + self.donations
  end

  def clear!
    clear_tickets
    clear_donations
  end
  
  def clear_tickets
    release_tickets
    self.tickets = []
  end

  def release_tickets
    tickets.each { |ticket| ticket.update_attribute(:cart, nil) }
  end

  def set_timeout(ticket)
    self.delay(:run_at => Time.now + 10.minutes).expire_ticket(ticket)
  end

  def expire_ticket(ticket)
    tickets.delete(ticket)
  end

  def items_subject_to_fee
    self.tickets.reject{|t| t.price == 0}
  end

  #
  # :( :( :(  Potential disaster
  #
  # The per ticket fee is hardcoded to 200 per ticket here.
  # The service_fee is recorded on the order *not* the item, so 
  # when refunding individual items we have to carve out 200 of whatever service_fee
  # is on the order.  When we move to allowing producers to "eat the fee", we'll have to address
  # refunds AND move the fee to the item, not the order
  #
  def fee_in_cents
    items_subject_to_fee.size * 200
  end

  def clear_donations
    temp = []

    #This won't work if there is more than 1 FAFS donation on the order
    donations.each do |donation|
      temp = donations.delete(donations)
    end
    temp
  end

  def <<(tkts)
    tickets << tkts
  end

  def total
    items.sum(&:price) + fee_in_cents
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
    tickets.each { |ticket| ticket.sell_to(person, order_timestamp) }
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
    Organization.find(donations.collect(&:organization_id))
  end

  def organizations_from_tickets
    Organization.find(tickets.collect(&:organization_id))
  end

  private
    def pay_with_authorization(payment, options)
      options[:settle] = true if options[:settle].nil?
      payment.authorize! ? approve! : reject!
      payment.settle! if options[:settle] and approved?
    end
end
