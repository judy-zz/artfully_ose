class DoorList
  attr_accessor :show

  def initialize(show)
    self.show = show
  end

  def items
    @items ||= show.tickets.select(&:committed?).collect do |ticket|
      Item.new(ticket, ticket.buyer)
    end.sort{ |a,b| (a.ticket.buyer.email || "") <=> (b.ticket.buyer.email || "") }
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