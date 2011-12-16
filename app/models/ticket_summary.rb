class TicketSummary
  attr_accessor :rows
  
  def initialize
    @rows = []
  end
  
  def has_show?(show)
    false
  end
  
  def <<(ticket)
    @rows << TicketSummary::Row.new(ticket) unless has_show?(ticket.show)
  end
  
  class TicketSummary::Row
    attr_accessor :quantity, :show, :event, :price, :ticket
    
    def initialize(ticket)
      @quantity = 1
      @ticket = ticket
      @show = ticket.show
      @event = ticket.show.event
      @price = ticket.sold_price
    end
  end
end