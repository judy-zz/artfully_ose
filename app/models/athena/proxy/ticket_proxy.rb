class Athena::Proxy::Ticket

  attr_reader :id

  def initialize(id)
    @id = id
  end

  def self.method_missing(name, *args, &block)
    Athena::Ticket.send(name, *args, &block)
  end

  def method_missing(name, *args, &block)
    @ticket ||= Athena::Ticket.find(@id)
    @ticket.send(name, *args, &block)
  end
end
