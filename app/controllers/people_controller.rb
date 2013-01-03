class PeopleController < ArtfullyOseController
  respond_to :html, :json

  def new
    authorize! :create, Person
    @person = Person.new
  end

  def create
    authorize! :create, Person
    @person = Person.new
    person = params[:person]

    @person.first_name       = person[:first_name]       unless person[:first_name].blank?
    @person.last_name        = person[:last_name]        unless person[:last_name].blank?
    @person.email            = person[:email]            unless person[:email].blank?
    @person.subscribed_lists = person[:subscribed_lists] unless person[:subscribed_lists].blank?
    @person.do_not_email     = person[:do_not_email]     unless person[:do_not_email].blank?
    @person.organization_id  = current_user.current_organization.id

    if @person.valid? && @person.save!
      @person.create_subscribed_lists_notes!(current_user)

      respond_to do |format|
        format.html do
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
    @person = Person.find(params[:id])
    authorize! :edit, @person

    results = @person.update_attributes(params[:person])

    respond_to do |format|
      format.html do
        if results
          @person.create_subscribed_lists_notes!(current_user)
          flash[:notice] = "Your changes have been saved"
          @person = Person.find(params[:id])
          redirect_to person_url(@person)
        else
          flash[:alert] = "Sorry, we couldn't save your changes. Make sure you entered a first name, last name or email address."
          render :edit
        end
      end

      format.json do
        if results
          render :json => @person
        else
          render :nothing => true
        end
      end
    end

  end

  def index
    authorize! :manage, Person
    @people = []

    if is_search(params)
      @people = Person.search_index(params[:search].dup, current_user.current_organization)
      respond_with do |format|
        format.csv  { render :csv => @people, :filename => "SearchResults-#{DateTime.now.strftime("%m-%d-%y")}.csv" }
        format.html { render :partial => 'list', :layout => false, :locals => { :people => @people } if request.xhr? }
        format.json { render :json => @people }
      end
    else
      @people = Person.recent(current_user.current_organization)
    end

    @people = @people.paginate(:page => params[:page], :per_page => 20)
  end

  def show
    @person = Person.find(params[:id])
    @orders = Order.where(:person_id => @person.id).includes(:person, :actions, :items).order(:created_at).paginate(:page => params[:page], :per_page => 25)
    authorize! :view, @person
  end

  def star
    render :nothing => true
    type = params[:type]
    starable = Action.find(params[:action_id])

    if starable.starred?
      starable.starred = false
    else
      starable.starred = true
    end
    starable.save
  end

  def edit
    @person = Person.find(params[:id])
    authorize! :edit, @person
  end

  def tag
    @person = Person.find(params[:id])
    authorize! :edit, @person
    @person.tag_list << params[:tag]
    @person.save
    render :nothing => true
  end

  def untag
    @person = Person.find(params[:id])
    authorize! :edit, @person
    @person.tag_list.remove(params[:tag])
    @person.save
    render :nothing => true
  end

  private
    def is_search(params)
      params[:commit].present?
    end    
    
    def without_winner
      if params[:winner]
        @winner = Person.find(params[:winner])
        render :merge and return
      else
        yield
      end
    end

end
