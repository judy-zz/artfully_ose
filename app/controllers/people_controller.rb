class PeopleController < ApplicationController
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
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

    if @person.valid? && @person.save!
      flash[:notice] = "Person created successfully!"
      redirect_to person_url(@person)
    else
      flash[:alert] = "Person could not be updated. Make sure it has a first name, last name or email address. "
      redirect_to :back
    end
  end

  def update
    @person = AthenaPerson.find(params[:id])
    authorize! :edit, @person
    person = params[:athena_person][:athena_person]

    @person.first_name = person[:first_name]
    @person.last_name  = person[:last_name]
    @person.email      = person[:email]

   if @person.valid? && @person.save!
      flash[:notice] = "Person updated successfully!"
      redirect_to person_url(@person)
    else
      flash[:alert] = "Person could not be updated. Make sure it has a first name, last name or email address. "
      redirect_to :back
    end
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
    @people = @people.paginate(:page => params[:page], :per_page => 10)
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