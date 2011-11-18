class Comp
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :show, :tickets, :recipient, :reason, :order
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
    ActiveRecord::Base.transaction do
      comped_tickets = []
      tickets.each do |ticket_id|
        t = Ticket.find ticket_id
        t.comp_to recipient
        comped_tickets << t
      end
      create_order(comped_tickets, benefactor)
      self.comped_count    = tickets.size
      self.uncomped_count  = 0
    end
  end

  private

  def create_order(comped_tickets, benefactor)
    @order = Order.new
    @order << comped_tickets
    @order.person = recipient
    @order.organization = benefactor.current_organization
    @order.details = "Comped by: #{benefactor.email} Reason: #{reason}"
    @order.to_comp!
    
    
    if 0 < comped_tickets.size
      @order.save
    end
  end
end