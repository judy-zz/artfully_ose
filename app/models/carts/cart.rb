class Cart < ActiveRecord::Base
  include ActiveRecord::Transitions

  has_many :donations, :dependent => :destroy
  has_many :tickets, :after_add => :set_timeout
  after_destroy :release_tickets

  attr_accessor :fee_in_cents
  after_initialize :update_ticket_fee

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

  def release_tickets
    tickets.each { |ticket| ticket.update_attribute(:cart, nil) }
  end

  def set_timeout(ticket)
    self.delay(:run_at => Time.now + 10.minutes).expire_ticket(ticket)
  end

  def expire_ticket(ticket)
    tickets.delete(ticket)
  end

  def update_ticket_fee
    @fee_in_cents = self.tickets.reject{|t| t.price == 0}.size * 200
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
    update_ticket_fee
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
    self.metric_sale_total
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

    def metric_sale_total
      bracket =
        case self.total
        when 0                  then "$0.00"
        when (1 ... 1000)       then "$0.01 - $9.99"
        when (1000 ... 2000)    then "$10 - $19.99"
        when (2000 ... 5000)    then "$20 - $49.99"
        when (5000 ... 10000)   then "$50 - $99.99"
        when (10000 ... 25000)  then "$100 - $249.99"
        when (25000 ... 50000)  then "$250 - $499.99"
        else                         "$500 or more"
        end

      RestfulMetrics::Client.add_compound_metric(ENV["RESTFUL_METRICS_APP"], "sale_complete", [ bracket ])
    end

end
