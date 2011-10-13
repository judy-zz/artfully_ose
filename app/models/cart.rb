class Cart < ActiveRecord::Base
  include ActiveRecord::Transitions

  has_many :donations, :dependent => :destroy
  has_many :tickets

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

  def clear_donations
    temp = []

    #This won't work if there is more than 1 FAFS donation on the order
    donations.each do |donation|
      temp = donations.delete(donations)
    end
    temp
  end

  def total
    items.sum(&:price)
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
