class TicketsController < ApplicationController

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  def bulk_edit
    authorize! :bulk_edit, :tickets
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]

    if @selected_tickets.nil?
      flash[:error] = "No tickets were selected"
      redirect_to performance_url(@performance) and return

    elsif 'Comp' == params[:commit]
      #works# render :comp_ticket_people
      
      with_person_search do
        render :comp_ticket_details and return
      end

#      with_person_search do
#        comp_ticket_people(@performance, @selected_tickets)
#        with_confirmation do
#          comp_ticket_details(@performance, @selected_tickets)
#          redirect_to performance_url(@performance) and return
#        end
#      end

    else
      with_confirmation do
        bulk_edit_tickets(@performance, @selected_tickets, params[:commit])
        redirect_to performance_url(@performance) and return
      end
    end
  end

  def comp_ticket_details
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]

  end

  def comp_ticket_confirm
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]
    with_confirmation_comp do
      comp_tickets(@performance, @selected_tickets)
      redirect_to performance_url(@performance) and return
    end
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

    def with_person_search
      @selected_tickets = params[:selected_tickets]
      @performance = AthenaPerformance.find(params[:performance_id])
      if params[:person].blank?  
        flash[:info] = "Please locate the person record for the person receiving the tickets."
        render :comp_ticket_people
      else
        yield
      end
    end

    def with_confirmation_comp
      if params[:confirmed].blank?
        @selected_tickets = params[:selected_tickets]
        @bulk_action = params[:commit]
        @performance = AthenaPerformance.find(params[:performance_id])
        flash[:info] = "with_confirmation_comp: Please confirm your changes before we save them."
        render 'tickets/comp_ticket_confirm' and return
      else
        yield
      end
    end

    def bulk_edit_tickets(performance, ticket_ids, action)
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

    def comp_tickets(performance, ticket_ids)
      #TODO:
      #rejected_ids = performance.bulk_edit_tickets(ticket_ids, "Comp")
      #edited_tickets = ticket_ids.size - rejected_ids.size
      mock_edited_tickets = ticket_ids.size
      rejected_ids = []
      @msg = "Mock Comped #{mock_edited_tickets.to_s} ticket(s)."
       if rejected_ids.size > 0
        @msg += rejected_ids.size.to_s + " ticket(s) could not be comped."
        flash[:alert] = @msg
      else
        flash[:notice] = @msg
      end
    end
end
