class Sale
  include ActiveModel::Validations

  attr_accessor :sections, :quantities
  attr_accessor :person

  validate :fulfilled?
  validate :has_tickets?

  def initialize(show, sections, quantities = {})
    @show       = show
    @sections   = sections
    @quantities = quantities
  end

  def tickets
    requests.collect(&:tickets).flatten
  end

  def sell(payment)
    if valid?
      cart.add_tickets(tickets)
      checkout = Checkout.new(cart, payment)
      checkout.finish.tap do |success|
        errors.add(:base, "payment was not accepted") and return if !success
        settle(checkout, success) if (success and !payment.requires_settlement?)
      end
    end
  end

  def cart
    @cart ||= Order.new
  end

  def fulfilled?
    errors.add(:base, "some of the requested sections were not available") unless requests.all?(&:fulfilled?)
    requests.all?(&:fulfilled?)
  end

  def has_tickets?
    errors.add(:base, "no tickets were added") unless tickets.size > 0
    tickets.size > 0
  end

  private

  def requests
    @requests ||= sections.collect { |section| Sale::TicketRequest.new(@show, section, @quantities[section.id]) }
  end

  def settle(checkout, success)
    Item.settle(checkout.athena_order.items, Settlement.new)
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

    @tickets ||= Ticket.available({
      :show_id => @show.id,
      :section        => @section.name,
      :price          => @section.price,
      :limit          => @quantity
    })
  end
end