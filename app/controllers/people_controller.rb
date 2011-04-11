class PeopleController < ApplicationController

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  def index
    @people = []
    if params[:email]
      begin
        person = AthenaPerson.find_by_email_and_organization(params[:email], current_user.current_organization)
      rescue
        flash[:error] = "No results found."
      end
    end
    @people << person unless person.nil?
  end

  def show
    @person = AthenaPerson.find(params[:id])
    authorize! :view, @person
  end

  def star
    render :nothing => true
    type = params[:type]
    if type == 'action'
      starable = AthenaAction.find(params[:action_id])
    else
      starable = AthenaRelationship.find(params[:action_id])
    end

    if starable.starred?
      starable.starred = false
    else
      starable.starred = true
    end
    starable.save
  end

  def edit
  end

  def update
  end

end