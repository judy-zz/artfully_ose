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

  def bulk_edit
    authorize! :bulk_edit, AthenaTicket
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]

    if @selected_tickets.nil?
      flash[:error] = "No tickets were selected"
      redirect_to event_performance_url(@performance.event, @performance) and return
    elsif 'Change Price' == params[:commit]
        render :set_new_price and return
    else
      with_confirmation do
        bulk_edit_tickets(@performance, @selected_tickets, params[:commit])
        redirect_to event_performance_url(@performance.event, @performance) and return
      end
    end
  end

  def confirm_new_price

  end

  private
    def with_confirmation
      if params[:confirmed].blank?
        @selected_tickets = params[:selected_tickets]
        @bulk_action = params[:commit]
        @performance = AthenaPerformance.find(params[:performance_id])
        flash[:info] = "Please confirm your changes before we save them."
        render 'tickets/' + params[:action] + '_confirm' and return
      else
        yield
      end
    end

    def bulk_edit_tickets(performance, ticket_ids, action)
      edited_tickets = performance.bulk_edit_tickets(ticket_ids, action)

      if edited_tickets
        case action
        when "Put on Sale"
          flash[:notice] = "Put #{to_plural(edited_tickets.size, 'ticket')} on sale. "
        when 'Take off Sale'
          flash[:notice] = "Took #{to_plural(edited_tickets.size, 'ticket')} off sale. "
        when 'Delete'
          flash[:notice] = "Deleted #{to_plural(edited_tickets.size, 'ticket')}. "
        else
          flash[:notice] = "Please select an action."
        end
      else
        flash[:error] = "Tickets that have been sold or comped can't be put on or taken off sale. A ticket that is already on sale or off sale can't be put on or off sale again."
      end
    end
end
