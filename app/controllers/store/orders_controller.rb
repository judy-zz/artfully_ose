class Store::OrdersController < Store::StoreController
  layout "cart"
  skip_before_filter :verify_authenticity_token

  def show
    @donations = current_order.generate_donations
  end

  def create
    handle_order(params)
    redirect_to store_order_url
  end

  def update
    handle_order(params)
    redirect_to store_order_url
  end

  def destroy
    current_order.destroy
    redirect_to store_order_url
  end

  private
    def handle_order(params)
      handle_tickets(params[:tickets]) if params.has_key? :tickets
      handle_donation(params[:donation]) if params.has_key? :donation
      current_order.update_ticket_fee

      unless current_order.save
        flash[:error] = current_order.errors
      end
    end

    def handle_tickets(ids)
      tickets = ids.collect { |id| AthenaTicket.find(id) }
      current_order.add_tickets tickets
    end

    def handle_donation(data)
      donation = Donation.new

      donation.amount = data[:amount]
      donation.organization = Organization.find(data.delete(:organization_id))

      current_order.donations << donation
    end
end
