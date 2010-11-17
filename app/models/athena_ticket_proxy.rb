class AthenaTicketProxy

  attr_reader :id

  def initialize(id)
    @id = id
  end

  def self.method_missing(name, *args, &block)
    AthenaTicket.send(name, *args, &block)
  end

  def method_missing(name, *args, &block)
    @ticket ||= AthenaTicket.find(@id)
    @ticket.send(name, *args, &block)
  end
end
