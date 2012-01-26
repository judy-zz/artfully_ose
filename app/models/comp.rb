class Comp
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :show, :tickets, :recipient, :reason, :order
  attr_accessor :comped_count, :uncomped_count

  #tickets can be an array of tickets_ids or an array of tickets
  def initialize(show, tickets_or_ids, recipient)
    @show = show
    @tickets = []
    load_tickets(tickets_or_ids)
    @recipient = recipient
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
      @tickets.each do |t|
        t.comp_to recipient
        comped_tickets << t
      end
      create_order(comped_tickets, benefactor)
      self.comped_count    = tickets.size
      self.uncomped_count  = 0
    end
  end

  private
    def load_tickets(tickets_or_ids)
      tickets_or_ids.each do |t|
        t = Ticket.find(t) unless t.kind_of? Ticket
        @tickets << t
      end
    end
  
    def create_order(comped_tickets, benefactor)
      @order = CompOrder.new
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