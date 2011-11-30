class BoxOfficeCart < Cart
  def update_ticket_fee
    @fee_in_cents = 0
  end
  
  def set_timeout(ticket)
    #no-op, don't lock tickets in box office
  end

end