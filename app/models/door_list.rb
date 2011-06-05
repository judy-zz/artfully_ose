class DoorList
  attr_accessor :performance

  def initialize(performance)
    self.performance = performance
  end

  def items
    @items ||= performance.tickets.select(&:committed?).collect do |ticket|
      Item.new(ticket, ticket.buyer)
    end
    @items.sort!{ |a,b| a.ticket.buyer.last_name.downcase <=> b.ticket.buyer.last_name.downcase }
  end

  private
    class Item
      attr_accessor :ticket, :buyer

      def initialize(ticket, buyer)
        self.ticket = ticket
        self.buyer = buyer
      end
    end
end