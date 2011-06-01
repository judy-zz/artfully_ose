class CompsController < ApplicationController
  def new
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]

    @comp = Comp.new(@performance, @selected_tickets, recipient)
  end

  def create
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]
    recipient = AthenaPerson.find(params[:person_id]) unless params[:person_id].blank?

    @comp = Comp.new(@performance, @selected_tickets, recipient)
    @comp.reason = params[:comp_reason]

    with_confirmation_comp do
      comp_tickets(@comp.recipient, @performance, @selected_tickets, @comp.reason)
      redirect_to event_performance_url(@performance.event, @performance) and return
    end
  end

  def with_confirmation_comp
    if params[:confirmed].blank?
      @selected_tickets = params[:selected_tickets]
      @performance = AthenaPerformance.find(params[:performance_id])
      flash[:info] = "Please confirm your changes before we save them."
      render 'comp_confirm' and return
    else
      yield
    end
  end

  private

  def recipient
    if params[:person_id]
      AthenaPerson.find(params[:person_id])
    elsif params[:comp] and params[:comp][:athena_person]
      rec = AthenaPerson.new(params[:comp][:athena_person].merge({:organization_id => current_user.current_organization.id}))
      rec.save!
    else
      AthenaPerson.find_or_new_by_email(params[:email], current_user.current_organization)
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
end