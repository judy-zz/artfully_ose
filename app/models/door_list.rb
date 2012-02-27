class DoorList
  attr_accessor :show

  def initialize(show)
    self.show = show
  end

  def items
    @items ||= show.tickets.includes(:buyer, :cart).select(&:committed?).collect do |ticket|
      Item.new(ticket, ticket.buyer)
    end.sort{ |a,b| (a.ticket.buyer.last_name || "") <=> (b.ticket.buyer.last_name || "") }
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
