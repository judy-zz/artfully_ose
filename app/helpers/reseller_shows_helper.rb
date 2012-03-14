module ResellerShowsHelper

  def ticket_reseller_name(ticket)
    return unless ticket.kind_of? Ticket

    ticket.reseller.name if ticket.reseller
  end

end
