class DoorList
  extend ::ApplicationHelper

  attr_accessor :show

  def initialize(show)
    self.show = show
  end

  def items
    @items ||= Ticket.where(:show_id => show.id).includes(:buyer).select(&:committed?).collect do |ticket|
      Item.new(ticket, ticket.buyer)
    end.sort{ |a,b| (a.ticket.buyer.last_name || "") <=> (b.ticket.buyer.last_name || "") }
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
    end
end
