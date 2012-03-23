class DoorList
  attr_reader :show
  extend ::ApplicationHelper

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
      attr_accessor :ticket, :buyer, :special_instructions
      
      comma do
        buyer("First Name") { |buyer| buyer.first_name }
        buyer("Last Name") { |buyer| buyer.last_name }
        buyer("Email") { |buyer| buyer.email }
        ticket("Section") { |ticket| ticket.section.name }
        ticket("Price") { |ticket| DoorList.number_as_cents ticket.price }
        ticket("Special Instructions") { |ticket| ticket.special_instructions }
      end

      def initialize(ticket, buyer)
        self.ticket = ticket
        self.buyer = buyer
        self.special_instructions = ticket.special_instructions
      end

      def <=>(obj)
        (self.ticket.buyer.last_name || "") <=> (obj.ticket.buyer.last_name || "")
      end
    end
end
