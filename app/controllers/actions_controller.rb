class ActionsController < ApplicationController

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  def new
    @action = AthenaAction.new
    @person = AthenaPerson.find params[:person_id]
    #flash[:alert] = "person: #{@person}"
  end

  def edit
    @action = AthenaAction.find params[:id]
    @person = AthenaPerson.find params[:person_id]
  end

  def create
    @person = AthenaPerson.find params[:person_id]

    #TODO: determine type of action to create based on action subtype
    act = params[:athena_action][:athena_action]
    @action = AthenaCommunicationAction.new

    @action.action_subtype = act[:action_subtype]
    @action.details = act[:details]
    @action.person = @person
    @action.creator_id = current_user.id
    @action.organization_id = current_user.current_organization.id
    @action.subject_id = @person.id
    @action.timestamp = DateTime.now

    #flash[:alert] = "params #{@action.attributes}"

    if @action.save
      flash[:notice] = "Action Logged successfully!"
    else
      flash[:notice] = "Action could not be logged"
    end

    redirect_to person_url(@person)
  end

  def update
    @person = AthenaPerson.find params[:person_id]

    #TODO: determine type of action to create based on action subtype
    act = params[:athena_action][:athena_action]
    @action = AthenaCommunicationAction.find params[:id]

    @action.action_subtype = act[:action_subtype]
    @action.details = act[:details]

    #flash[:alert] = "UPDATE: params #{params} action#{@action.attributes}"

    if @action.save
      flash[:notice] = "Action updated successfully!"
    else
      flash[:notice] = "Action could not be updated"
    end

    redirect_to person_url(@person)
  end

end
