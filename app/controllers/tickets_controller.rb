class TicketsController < ApplicationController

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to dashboard_path
  end

  def on_sale
    authorize! :bulk_edit, AthenaTicket
    with_confirmation do
      @performance = AthenaPerformance.find(params[:performance_id])
      @selected_tickets = params[:selected_tickets]
      if @performance.bulk_on_sale(@selected_tickets)
        flash[:notice] = "Put #{to_plural(@selected_tickets.size, 'ticket')} on sale. "
      else
        flash[:error] = "Tickets that have been sold or comped can't be put on or taken off sale. A ticket that is already on sale or off sale can't be put on or off sale again."
      end
      redirect_to event_performance_url(@performance.event, @performance)
    end
  end

  def off_sale
    authorize! :bulk_edit, AthenaTicket
    with_confirmation do
      @performance = AthenaPerformance.find(params[:performance_id])
      @selected_tickets = params[:selected_tickets]
      if @performance.bulk_off_sale(@selected_tickets)
        flash[:notice] = "Take #{to_plural(@selected_tickets.size, 'ticket')} off sale. "
      else
        flash[:error] = "Tickets that have been sold or comped can't be put on or taken off sale. A ticket that is already on sale or off sale can't be put on or off sale again."
      end
      redirect_to event_performance_url(@performance.event, @performance)
    end
  end

  def delete
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]
    if @performance.bulk_delete(@selected_tickets)
      flash[:notice] = "Deleted #{to_plural(@selected_tickets.size, 'ticket')}. "
    else
      flash[:error] = "Tickets that have been sold or comped can't be put on or taken off sale. A ticket that is already on sale or off sale can't be put on or off sale again."
    end
    redirect_to event_performance_url(@performance.event, @performance)
  end

  def bulk_edit
    authorize! :bulk_edit, AthenaTicket
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]

    if @selected_tickets.nil?
      flash[:error] = "No tickets were selected"
      redirect_to event_performance_url(@performance.event, @performance) and return
    elsif 'Update Price' == params[:commit]
        set_new_price
    else
      with_confirmation do
        bulk_edit_tickets(@performance, @selected_tickets, params[:commit])
        redirect_to event_performance_url(@performance.event, @performance) and return
      end
    end
  end

  def set_new_price
    @performance = AthenaPerformance.find(params[:performance_id])
    unless @performance.event.is_free == "true"
      @selected_tickets = params[:selected_tickets]
      tix = @selected_tickets.collect{|id| AthenaTicket.find( id )}
      sections = tix.group_by(&:section)
      @grouped_tickets = Hash[ sections.collect{ |name, tix| [name, tix.group_by(&:price)] } ]
      render 'tickets/set_new_price' and return
    else
      flash[:alert] = "You cannot change the ticket prices of a free event."
      redirect_to event_performance_url(@performance.event, @performance) and return
    end
  end

  def update_prices
    @grouped_tickets = params[:grouped_tickets]

    with_confirmation_price_change do
      @selected_tickets = params[:selected_tickets]
      @price = params[:price]
      @performance = AthenaPerformance.find(params[:performance_id])

      if @performance.bulk_update_price(@selected_tickets, @price)
        flash[:notice] = "Updated the price of #{to_plural(@selected_tickets.size, 'ticket')}. "
      else
        flash[:error] = "Tickets that have been sold or comped can't be given a new price."
      end

      redirect_to event_performance_url(@performance.event, @performance) and return
    end
  end

  private
    def with_confirmation
      if params[:confirmed].blank?
        @selected_tickets = params[:selected_tickets]
        @bulk_action = params[:commit]
        @performance = AthenaPerformance.find(params[:performance_id])
        flash[:info] = "Please confirm your changes before we save them."
        render "tickets/#{params[:action]}/confirm" and return
      else
        yield
      end
    end

    def with_confirmation_price_change
      @selected_tickets = params[:selected_tickets]

      if params[:confirmed].blank?
        @price = params[:price]

        #TODO: This is rebuilding a list of tickets by hitting ATHENA a second time, needs to be refactored
        #(temporary fix b/c passing around complex nested arrays/hashes via params is also painful)
        tix = @selected_tickets.collect{|id| AthenaTicket.find( id )}
        sections = tix.group_by(&:section)
        @grouped_tickets = Hash[ sections.collect{ |name, tix| [name, tix.group_by(&:price)] } ]
        @performance = AthenaPerformance.find(params[:performance_id])
        flash[:info] = "Please confirm your changes before we save them."
        render 'tickets/confirm_new_price' and return
      else
        yield
      end
    end
end
