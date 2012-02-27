module ResellerShowsHelper

  def ticket_reseller_name(ticket)
    return unless ticket
    return unless ticket.cart.kind_of?(Reseller::Cart)
    return unless ticket.cart.reseller

    ticket.cart.reseller.name
  end
end
