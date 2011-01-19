class TicketsController < ApplicationController
  
  def index
    @tickets = AthenaTicket.search(params)
    respond_to do |format|
      format.jsonp  { render_jsonp (@tickets.to_json) }
    end
  end
  
  def bulk_edit
    authorize! :bulk_edit, :tickets
    with_confirmation do
      @performance = AthenaPerformance.find(params[:performance_id])
      bulk_edit_tickets (@performance, params[:selected_tickets], params[:bulk_action])
      redirect_to performance_url(@performance) and return
    end
  end
  
  private    
    def with_confirmation
      if params[:confirm].nil?
        @selected_tickets = params[:selected_tickets]
        @bulk_action = params[:bulk_action]      
        @performance = AthenaPerformance.find(params[:performance_id])
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
          when "PUT_ON_SALE"
            @msg = "Put " + edited_tickets.to_s + " ticket(s) on sale. "
          when 'TAKE_OFF_SALE'
            @msg = "Took " + edited_tickets.to_s + " ticket(s) off sale. "
          when 'DELETE'
            @msg = "Deleted " + edited_tickets.to_s + " ticket(s). "
          else
            @msg = "Please select an action. "
        end
        
        if rejected_ids.size > 0
          @msg += rejected_ids.size.to_s + " ticket(s) could not be edited because they have already been sold"
          flash[:alert] = @msg
        else          
          flash[:notice] = @msg
        end
      end
    end
end
