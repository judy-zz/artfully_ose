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
      bulk_edit_tickets params[:selected_tickets], params[:bulk_action]
      @performance = AthenaPerformance.find(params[:performance_id])
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
  
    def bulk_edit_tickets ticket_ids, action
      if ticket_ids.nil?
        flash[:error] = "You didn't select any tickets"
        return
      elsif action.nil?
        flash[:error] = "You didn't select an action"
        return     
      else
        ticket_ids.each do |ticket_id|
          @ticket = AthenaTicket.find(ticket_id)

          #TODO: Put this logic into @performance model?
          case action
            when "PUT_ON_SALE"
              @ticket.on_sale=true
              @ticket.save
            when 'TAKE_OFF_SALE'
              @ticket.on_sale=false
              @ticket.save
            when 'DELETE'
              @ticket.destroy
          end
        end

        case action
          when "PUT_ON_SALE"
            @msg = "Put " + ticket_ids.size.to_s + " ticket(s) on sale"
          when 'TAKE_OFF_SALE'
            @msg = "Took " + ticket_ids.size.to_s + " ticket(s) off sale"
          when 'DELETE'
            @msg = "Deleted " + ticket_ids.size.to_s + " ticket(s) "
          else
            @msg = "Please select some tickets"
        end
      end
      flash[:notice] = @msg
    end
end
