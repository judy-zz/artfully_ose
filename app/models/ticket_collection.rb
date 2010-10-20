class TicketCollection
  def initialize(tickets = [])
    @tickets = tickets
  end

  def method_missing(name, *args, &block)
    fetch_all! if %w( each ).include? name.to_s
    raw.send(name, *args, &block)
  end

  def fetch_all!
    @tickets = raw.collect do |ticket|
      to_ticket(ticket)
    end
  end

  def first
    raw[0] = to_ticket(raw.first)
  end

  def to_a
    raw.collect { |ticket| ticket.id}
  end

  def raw
    @tickets ||= []
  end

  private
    def to_ticket(ticket)
      ticket.kind_of?(Ticket) ? ticket : Ticket.find(ticket)
    end
end
