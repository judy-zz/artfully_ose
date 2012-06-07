class Api::TicketsController < ApiController
  def index
    @tickets = Ticket.available(conditions, params[:limit])
    respond_to do |format|
      format.json { render :json => @tickets.to_json }
    end
  end

  private

  def conditions
    if params[:section_id].present?
      { :show_id => params[:show_id], :section_id => params[:section_id] }
    else
      { :show_id => params[:show_id], :price => params[:price] }
    end
  end
end
