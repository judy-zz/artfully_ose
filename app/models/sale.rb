class Sale
  attr_accessor :sections, :quantities
  attr_accessor :person

  def initialize(show, sections, quantities = {})
    @show       = show
    @sections   = sections
    @quantities = quantities
  end

  def tickets
    requests.collect(&:tickets).flatten
  end

  def sell(payment)
    if fulfilled? and has_tickets?
      cart.add_tickets(tickets)
      checkout = Checkout.new(cart, payment)
      checkout.finish
    end
  end

  def cart
    @cart ||= Order.new
  end

  def fulfilled?
    requests.all?(&:fulfilled?)
  end

  def has_tickets?
    tickets.size > 0
  end

  private

  def requests
    @requests ||= sections.collect { |section| Sale::TicketRequest.new(@show, section, @quantities[section.id]) }
  end
end


class Sale::TicketRequest
  attr_reader :quantity

  def initialize(show, section, quantity)
    @show     = show
    @section  = section
    @quantity = quantity.to_i
  end

  def fulfilled?
    tickets.size == @quantity
  end

  def tickets
    return [] if @quantity == 0

    @tickets ||= AthenaTicket.available({
      :performance_id => @show.id,
      :section        => @section.name,
      :price          => @section.price,
      :limit          => @quantity
    })
  end
end