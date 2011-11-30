class Sale
  include ActiveModel::Validations

  attr_accessor :sections, :quantities, :tickets, :cart, :message, :sale_made
  attr_accessor :person

  validate :has_tickets?

  def initialize(show, sections, quantities = {})
    @show       = show
    @sections   = sections
    
    #When coming from a browser, all keys and values in @quantities are STRINGS
    @quantities = quantities
    @cart       = BoxOfficeCart.new
    @tickets     = []
    
    #This is irritating, it means you can't add tickets to a sale later
    load_tickets
    cart.tickets << tickets
  end

  def sell(payment)
    if valid?
      # cart.tickets << tickets
      # checkout = Checkout.new(cart, payment)
      # checkout.finish.tap do |success|
      #   errors.add(:base, "payment was not accepted") and return if !success
      #   settle(checkout, success) if (success and !payment.requires_settlement?)
      # end
      self.sale_made = true
      self.sale_made
    end
  end

  def load_tickets
    sections.each do |section|
      tickets_available_in_section = Ticket.available({:section_id => section.id, :show_id => @show.id}, @quantities[section.id.to_s])
      if tickets_available_in_section.length != @quantities[section.id.to_s].to_i
        errors.add(:base, "Not enough tickets in section")
      else
        @tickets = @tickets + tickets_available_in_section
      end
    end
  end

  def has_tickets?
    errors.add(:base, "no tickets were added") unless @tickets.size > 0
    @tickets.size > 0
  end

  private

    def settle(checkout, success)
      Item.settle(checkout.order.items, Settlement.new)
    end
end