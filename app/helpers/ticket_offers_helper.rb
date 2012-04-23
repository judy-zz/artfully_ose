module TicketOffersHelper

  def reseller_offer_control(offer)
    buttons = []

    case offer.status
    when "offered"
      buttons << button_to("Accept", accept_ticket_offer_path(offer), :class => "accept button btn", :method => :get)
      buttons << button_to("Decline", decline_ticket_offer_path(offer), :class => "decline button btn", :method => :get)
    end

    raw buttons.join(" ")
  end

  def producer_offer_control(offer)
    buttons = []

    case offer.status
    when "creating"
      buttons << button_to("Prepare", edit_ticket_offer_path(offer), :class => "button btn", :method => :get)
    end

    raw buttons.join(" ")
  end

end
