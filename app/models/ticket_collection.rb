class TicketCollection
  def initialize(tickets)
    @tickets ||= tickets.nil?? [] : tickets
  end

  def method_missing(name, *args, &block)
    @tickets.send(name, *args, &block)
  end

  def to_a
    @tickets.collect { |ticket| ticket.id}
  end
end
