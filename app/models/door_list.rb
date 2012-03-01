class DoorList
  attr_reader :show

  def initialize(show)
    @show = show
  end

  def tickets
    @tickets ||= Ticket.where(:show_id => show.id).includes(:buyer, :cart).select(&:committed?)
  end

  def items
    @items ||= tickets.map { |t| Item.new t, t.buyer }.sort
  end

  private

    class Item
      attr_accessor :ticket, :buyer

      def initialize(ticket, buyer)
        self.ticket = ticket
        self.buyer = buyer
      end

      def <=>(obj)
        (self.ticket.buyer.last_name || "") <=> (obj.ticket.buyer.last_name || "")
      end
    end
end
