class PeopleController < ApplicationController
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  rescue_from ActiveResource::ResourceInvalid do |exception|
    flash[:alert] = "#{exception.message} Person records must have a first name, last name or email address to be saved. "
    redirect_to new_person_path
  end

  def new
    authorize! :create, AthenaPerson
    @person = AthenaPerson.new
  end

  def create
    authorize! :create, AthenaPerson
    @person = AthenaPerson.new
    person = params[:athena_person][:athena_person]

    @person.first_name      = person[:first_name] unless person[:first_name].blank?
    @person.last_name       = person[:last_name]  unless person[:last_name].blank?
    @person.email           = person[:email]      unless person[:email].blank?
    @person.organization_id = current_user.current_organization.id

    if @person.save!
      flash[:notice] = "Person updated successfully!"
    else
      flash[:notice] = "Person could not be updated"
    end

    redirect_to person_url(@person) unless @person.id.nil?
  end

  def update
    @person = AthenaPerson.find(params[:id])
    authorize! :edit, @person
    person = params[:athena_person][:athena_person]
    
    @person.first_name      = person[:first_name] unless person[:first_name].blank?
    @person.last_name       = person[:last_name]  unless person[:last_name].blank?
    @person.email           = person[:email]      unless person[:email].blank?

    if @person.save
      flash[:notice] = "Person updated successfully!"
    else
      flash[:notice] = "Person could not be updated"
    end

    redirect_to person_url(@person)
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
    @person = AthenaPerson.find(params[:id])
    authorize! :edit, @person
  end

end