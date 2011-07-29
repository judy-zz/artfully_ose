class PeopleController < ApplicationController
  respond_to :html, :json

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
      respond_to do |format|
        format.html do
          flash[:notice] = "Person created successfully!"
          redirect_to person_url(@person)
        end

        format.json do
          render :json => @person.as_json
        end
      end
    else
      respond_to do |format|
        format.html do
          render :new
        end

        format.json do
          render :json => @person.as_json.merge(:errors => @person.errors.full_messages), :status => 400
        end
      end
    end
  end

  def update
    @person = AthenaPerson.find(params[:id])
    authorize! :edit, @person

   if @person.update_attributes(params[:athena_person][:athena_person])
      flash[:notice] = "Person updated successfully!"
      redirect_to person_url(@person)
    else
      flash[:alert] = "Person could not be updated. Make sure it has a first name, last name or email address. "
      render :edit
    end
  end

  def index
    authorize! :manage, AthenaPerson
    @people = []
    if is_search(params)
      @people = AthenaPerson.search_index(params[:search], current_user.current_organization)
      respond_with do |format|
        if request.xhr?
          format.html do
            render :partial => 'list', :layout => false, :locals => { :people => @people }
          end
        end
      end
    else
      @people = AthenaPerson.recent(current_user.current_organization)
    end
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
  
  def tag
    
  end

  private
    def is_search(params)
      !params[:commit].nil? && params[:commit].eql?('Search')
    end

end