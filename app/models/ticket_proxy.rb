class TicketProxy

  attr_reader :id

  def initialize(id)
    @id = id
  end

  def method_missing(name, *args, &block)
    @ticket ||= Ticket.find(@id)
    @ticket.send(name, *args, &block)
  end
end
