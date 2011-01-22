module TicketTableHelper
  def ticket_status(ticket)
    if ticket.sold?
      'Sold'
    elsif ticket.on_sale?
      'On sale'
    else
      'Not on sale'
    end
  end
end