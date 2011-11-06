class Comp
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :show, :tickets, :recipient, :reason
  attr_accessor :comped_count, :uncomped_count

  def initialize(show, tickets, recipient)
    self.show = show
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
    comped_ids      = show.bulk_comp_to(tickets, recipient)
    puts "@@@@@@@@@@@@"
    puts tickets
    puts "@@@@@@@@@@@@"
    comped_tickets  = comped_ids.collect{|id| Ticket.find(id)}
    create_order(comped_tickets, benefactor)
    puts "@@@@@@@@@@@@"
    puts comped_tickets
    puts "@@@@@@@@@@@@"

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