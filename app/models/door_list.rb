class DoorList
  attr_accessor :performance

  def initialize(performance)
    self.performance = performance
  end

  def items
    @items ||= performance.tickets.select(&:committed?).collect do |ticket|
      Item.new(ticket, ticket.buyer)
    end.sort{ |a,b| a.ticket.buyer.email <=> b.ticket.buyer.email }
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