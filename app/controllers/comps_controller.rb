class CompsController < ApplicationController
  def new
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]

    @comp = Comp.new(@performance, @selected_tickets, recipient)
  end

  def create
    @performance = AthenaPerformance.find(params[:performance_id])
    @selected_tickets = params[:selected_tickets]

    @comp = Comp.new(@performance, @selected_tickets, recipient)
    @comp.reason = params[:comp_reason]

    with_confirmation_comp do
      @comp.submit(current_user)
      if @comp.uncomped_count > 0
        flash[:alert] = "Comped #{to_plural(@comp.comped_count, 'ticket')}. #{to_plural(@comp.uncomped_count, 'ticket')} could not be comped."
      else
        flash[:notice] = "Comped #{to_plural(@comp.comped_count, 'ticket')}."
      end

      redirect_to event_performance_url(@performance.event, @performance)
    end
  end

  def with_confirmation_comp
    if params[:confirmed].blank?
      flash[:info] = "Please confirm your changes before we save them."
      render 'comp_confirm' and return
    else
      yield
    end
  end

  private

  def recipient
    logger.info("Uhhh....")
    if params[:person_id]
      AthenaPerson.find(params[:person_id])
    elsif params[:comp] and params[:comp][:athena_person]
      rec = AthenaPerson.new(params[:comp][:athena_person].merge({:organization_id => current_user.current_organization.id}))
      rec.save!
      logger.debug(rec)
      rec
    else
      AthenaPerson.find_or_new_by_email(params[:email], current_user.current_organization)
    end
  end
end