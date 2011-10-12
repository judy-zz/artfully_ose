class Comp
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :performance, :tickets, :recipient, :reason
  attr_accessor :comped_count, :uncomped_count

  def initialize(performance, tickets, recipient)
    self.performance = performance
    self.tickets = tickets
    self.recipient = recipient
  end

  def has_recipient?
    !recipient.blank?
  end

  def persisted?
    false
  end

  def submit(benefactor)
    comped_ids      = performance.bulk_comp_to(tickets, recipient)
    comped_tickets  = comped_ids.collect{|id| AthenaTicket.find(id)}

    create_order(comped_tickets, benefactor)

    self.comped_count    = comped_tickets.size
    self.uncomped_count  = self.tickets.size - self.comped_count
  end

  private

  def create_order(comped_tickets, benefactor)
    order = Order.new.tap do |order|
      order << comped_tickets
      order.person = recipient
      order.organization = benefactor.current_organization
      order.details = "Comped by: #{benefactor.email} Reason: #{reason}"
    end

    if 0 < comped_tickets.size
      order.save
    end
  end
end