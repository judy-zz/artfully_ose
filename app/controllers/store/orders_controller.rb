class Store::OrdersController < Store::StoreController

  def sync
    current_cart.clear!
    
    order_params = {}

    if params[:sections]
      ticket_ids = []
      over_section_limit = []
      params[:sections].each_value do |section|
        puts "#{section[:section_id]}: #{section[:limit]}"
        ids = Ticket.available(
          {
            :section_id => section[:section_id],
            :show_id => section[:show_id]
          },
          section[:limit]
        ).collect(&:id)
        
        if ids.length < section[:limit].to_i
          over_section_limit << {:section_id => section[:section_id], :show_id => section[:show_id], :limit => ids.length}
        end
        ticket_ids += ids
      end
      order_params = order_params.merge(:tickets => ticket_ids) if ticket_ids.any?
    end
    order_params = order_params.merge(:donation => params[:donation]) if params[:donation]
    handle_order(order_params)

    response = current_cart.as_json
    response = response.merge(:total => current_cart.total)
    response = response.merge(:service_charge => current_cart.fee_in_cents)
    response = response.merge(:over_section_limit => over_section_limit).to_json
    render :json => response
  end

  private

    def handle_order(params)
      handle_tickets(params[:tickets]) if params.has_key? :tickets
      handle_donation(params[:donation]) if params.has_key? :donation

      unless current_cart.save
        flash[:error] = current_cart.errors
      end
    end

    def handle_tickets(ids)
      Ticket.find(ids).each do |ticket|
        if current_cart.can_hold? ticket
          current_cart << ticket
        else
          flash[:error] = "Your cart cannot hold any more tickets."
        end
      end
    end

    def handle_donation(data)
      if data[:amount].to_i == 0
        flash[:error] = "Please enter a donation amount."
        return
      end
      
      donation = Donation.new

      donation.amount = data[:amount]
      donation.organization = Organization.find(data.delete(:organization_id))

      current_cart.donations << donation
    end
end
