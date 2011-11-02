class ActionsController < ApplicationController

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  def new
    @action = AthenaAction.new
    @person = Person.find(params[:person_id])

    @action.creator = nil
    @action.occurred_at = DateTime.now.in_time_zone(current_user.current_organization.time_zone)
    render :layout => false
  end

  def edit
    @action = AthenaAction.find(params[:id])
    @person = Person.find(params[:person_id])

    @action.creator = User.find(@action.creator_id).email
    render :layout => false
  end

  def create
    @person = Person.find(params[:person_id])

    @action = AthenaAction.create_of_type(params[:action_type])
    @action.set_params(params[:athena_action][:athena_action], @person, current_user)

    logger.debug(@action.valid?)
    logger.debug(@action.errors)

    if @action.save
      flash[:notice] = "Action logged successfully!"
      redirect_to person_url(@person)
    else
      flash[:alert] = "One or more fields are invalid!"
      redirect_to :back
    end

  end

  def update
    @person = Person.find params[:person_id]

    @action = AthenaAction.find params[:id]
    @action.set_params(params[:athena_action][:athena_action], @person, current_user)

    if @action.valid? && @action.save!
      flash[:notice] = "Action updated successfully!"
      redirect_to person_url(@person)
    else
      flash[:alert] = "One or more fields are invalid!"
      redirect_to :back
    end

  end

end
