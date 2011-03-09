module TicketTableHelper
  def ticket_status(ticket)
    if ticket.on_sale?
      'On Sale'
    elsif ticket.off_sale?
      'Off Sale'
    elsif ticket.sold?
      'Sold'
    elsif ticket.comped?
      'Comped'
    end    
  end
end