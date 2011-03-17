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
      with_person_search do
        render :comp_ticket_details and return
      end
    else
      with_confirmation do
        bulk_edit_tickets(@performance, @selected_tickets, params[:commit])
        redirect_to performance_url(@performance) and return
      end
    end
  end

  def comp_ticket_details
    @selected_tickets = params[:selected_tickets]
    if person = AthenaPerson.find_by_email(params[:email]).first
      flash[:info] = "Person record found."
      @person = person
    else
      flash[:alert] = "Person record not found! You can create a person record directly from this page, or go back an try searching again."
      @person = AthenaPerson.new(:email=>params[:email])
    end
    @person_id = @person.id
  end

  def comp_ticket_confirm
    @performance = AthenaPerformance.find(params[:performance_id])
    @reason_for_comp = params[:comp_reason]
    @selected_tickets = params[:selected_tickets]
    @person = params[:athena_person]
    @person_id = params[:person_id]

    @confirmed = params[:confirmed]
    unless @confirmed
      if @person_id == ""
        @athena_person = AthenaPerson.new(:email=> @person[:athena_person][:email], :first_name=> @person[:athena_person][:first_name], :last_name=> @person[:athena_person][:last_name])
      else
        @athena_person = AthenaPerson.find(@person_id)
      end

      if @athena_person.save
        if @person_id == ""
          flash[:notice] = "Person record created!"
        end
        @person_id = @athena_person.id
      else
        flash[:notice] = "Person record could not be created!"
      end
    end

    with_confirmation_comp do
        @user = User.new #TODO: Get current user
        @athena_person = AthenaPerson.find(params[:person_id])
        comp_tickets(@athena_person, @user, @performance, @selected_tickets)
        redirect_to performance_url(@performance) and return
    end
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
        flash[:info] = "Please confirm your changes before we save them."
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

    def comp_tickets(person, user, performance, ticket_ids)
      comped_ids = performance.bulk_comp_to(ticket_ids, person)
      comped_tickets = comped_ids.collect{|id| AthenaTicket.find(id)}

      order = AthenaOrder.new.tap do |order|
        order.for_organization Organization.find(performance.event.organization_id)
        order.for_items comped_tickets
        order.person = person
        #TODO: save the user who is comping the tickets
        #order.user = user
      end
      order.save
      
      num_rejected_tickets = ticket_ids.size - comped_ids.size
      @msg = "Comped #{comped_ids.size.to_s} ticket(s). "
     
      if num_rejected_tickets > 0
        @msg += num_rejected_tickets.to_s + " ticket(s) could not be comped. "
        flash[:alert] = @msg
      else
        flash[:notice] = @msg
      end
    end
end
