class TicketsController < ApplicationController

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  def bulk_edit
    authorize! :bulk_edit, :tickets
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]
    if 'Comp' == params[:commit]
      redirect_to comp_ticket_people_url(@performance, @selected_tickets) and return #comp_ticket_people#(@performance, params[:selected_tickets], params[:commit])
    else
      with_confirmation do
        #@performance = AthenaPerformance.find(params[:performance_id])
        bulk_edit_tickets(@performance, params[:selected_tickets], params[:commit])
        redirect_to performance_url(@performance) and return
      end
    end
  end

  def comp_ticket_details
#    if not params[:email].blank? and @user = User.find_by_email(params[:email])
#     else
#      redirect_to comp_ticket_people_path
#    end
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]
  end

  def comp_ticket_confirmation
    flash[:info] = "Please confirm your changes before we save them."
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]
  end

#  def comp_ticket_confirmation(performance, selected_tickets)
#    flash[:info] = "Please confirm your changes before we save them."
#    @performance = AthenaPerformance.find(params[:performance_id])
#    @selected_tickets = selected_tickets
#  end

  def comp_ticket_people
   @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]
  end

#  def comp_ticket_people(performance, selected_tickets)
#    @performance = performance
#    @selected_tickets = selected_tickets
#  end

  def comp_ticket_details_people_not_found
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]
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
      if ticket_ids.nil?
        flash[:error] = "You didn't select any tickets"
        return
      elsif action.nil?
        flash[:error] = "You didn't select an action"
        return
      else
        rejected_ids = performance.bulk_edit_tickets(ticket_ids, action)
        edited_tickets = ticket_ids.size - rejected_ids.size
        case action
          when "Put on Sale"
            @msg = "Put #{edited_tickets.to_s} ticket(s) on sale. "
          when 'Take off Sale'
            @msg = "Took #{edited_tickets.to_s} ticket(s) off sale. "
          when 'Delete'
            @msg = "Deleted #{edited_tickets.to_s} ticket(s). "
          else
            @msg = "Please select an action. "
        end

        if rejected_ids.size > 0
          @msg += rejected_ids.size.to_s + " ticket(s) could not be edited.
                Tickets that have been sold or comped can't be put on or taken off sale.
                A ticket that is already on sale or off sale can't be put on or off sale again."
          flash[:alert] = @msg
        else
          flash[:notice] = @msg
        end
      end
    end

#    def comp_tickets(performance, ticket_ids, action)
#    end

end
