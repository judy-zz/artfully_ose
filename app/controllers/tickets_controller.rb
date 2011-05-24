class TicketsController < ApplicationController

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to dashboard_path
  end

  def bulk_edit
    authorize! :bulk_edit, AthenaTicket
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]

    if @selected_tickets.nil?
      flash[:error] = "No tickets were selected"
      redirect_to event_performance_url(@performance.event, @performance) and return
    elsif 'Comp' == params[:commit]
      with_person_search do
        render :comp_ticket_details and return
      end
    elsif 'Change Price' == params[:commit]
        render :set_new_price and return
    else
      with_confirmation do
        bulk_edit_tickets(@performance, @selected_tickets, params[:commit])
        redirect_to event_performance_url(@performance.event, @performance) and return
      end
    end
  end

  def comp_details
    @selected_tickets = params[:selected_tickets]
    if person = AthenaPerson.find_by_email_and_organization(params[:email], current_user.current_organization)
      flash[:info] = "Person record found."
      @person = person
    else
      flash[:alert] = "Person record not found! You can create a person record directly from this page, or go back an try searching again."
      @person = AthenaPerson.new(:email=>params[:email])
    end
    @person_id = @person.id
  end

  def comp_confirm
    @performance = AthenaPerformance.find(params[:performance_id])
    @reason_for_comp = params[:comp_reason]
    @selected_tickets = params[:selected_tickets]
    @person = params[:athena_person]
    @person_id = params[:person_id]

    @confirmed = params[:confirmed]
    unless @confirmed
      @reason_for_comp = params[:comp_reason]
      if @person_id == ""
        @athena_person = AthenaPerson.new(:email=> @person[:athena_person][:email], :first_name=> @person[:athena_person][:first_name], :last_name=> @person[:athena_person][:last_name], :organization_id=>current_user.current_organization.id)
      else
        @athena_person = AthenaPerson.find(@person_id)
      end

      if @athena_person.save
        if @person_id == ""
          flash[:notice] = "Person record created!"
        end
        @person_id = @athena_person.id
      else
        flash[:alert] = "Person record could not be created!"
      end
    end

    with_confirmation_comp do
        @athena_person = AthenaPerson.find(params[:person_id])
        comp_tickets(@athena_person, @performance, @selected_tickets, params[:reason_for_comp])
        redirect_to event_performance_url(@performance.event, @performance) and return
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

    def with_person_search
      @selected_tickets = params[:selected_tickets]
      @performance = AthenaPerformance.find(params[:performance_id])
      if params[:person].blank?
        flash[:info] = "Please locate the person record for the person receiving the tickets."
        render :comp_people
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
        render 'tickets/comp_confirm' and return
      else
        yield
      end
    end

    def bulk_edit_tickets(performance, ticket_ids, action)
      rejected_ids = performance.bulk_edit_tickets(ticket_ids, action)
      edited_tickets = ticket_ids.size - rejected_ids.size

      case action
      when "Put on Sale"
        @msg = "Put #{to_plural(edited_tickets, 'ticket')} on sale. "
      when 'Take off Sale'
        @msg = "Took #{to_plural(edited_tickets, 'ticket')} off sale. "
      when 'Delete'
        @msg = "Deleted #{to_plural(edited_tickets, 'ticket')}. "
      else
        @msg = "Please select an action. "
      end

      if rejected_ids.size > 0
        @msg += "#{to_plural(rejected_ids.size, 'ticket')} could not be edited.
                Tickets that have been sold or comped can't be put on or taken off sale.
                A ticket that is already on sale or off sale can't be put on or off sale again."
        flash[:alert] = @msg
      else
        flash[:notice] = @msg
      end
    end

    def comp_tickets(person, performance, ticket_ids, reason_for_comp)
      comped_ids = performance.bulk_comp_to(ticket_ids, person)
      comped_tickets = comped_ids.collect{|id| AthenaTicket.find(id)}

      order = AthenaOrder.new.tap do |order|
        order.for_organization Organization.find(performance.event.organization_id)
        order.for_items comped_tickets
        order.person = person
        order.organization = current_user.current_organization
        order.details = "Comped by: #{current_user.email} Reason: #{reason_for_comp}"
        order.transaction_id = nil
      end

      if 0 < comped_tickets.size
        order.save
      end
      
      num_rejected_tickets = ticket_ids.size - comped_ids.size
      @msg = "Comped #{to_plural(comped_ids.size, 'ticket')}. "
      if num_rejected_tickets > 0
        @msg += "#{to_plural(num_rejected_tickets, 'ticket')} could not be comped. "
        flash[:alert] = @msg
      else
        flash[:notice] = @msg
      end
    end

    def to_plural(variable, word)
      self.class.helpers.pluralize(variable, word)
    end
end
