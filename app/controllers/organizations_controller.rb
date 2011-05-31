class OrganizationsController < ApplicationController
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to dashboard_path
  end

  def index
    if current_user.is_in_organization?
      redirect_to organization_url(current_user.current_organization)
    else
      redirect_to new_organization_url
    end
  end

  def show
    @organization = Organization.find(params[:id])
    authorize! :view, @organization

    @fa_user = FA::User.new
    @kits = @organization.available_kits
  end

  def new
    unless current_user.current_organization.new_record?
      flash[:error] = "You can only join one organization at this time."
      redirect_to organizations_url
    end

    @organization = Organization.new
  end

  def create
    @organization = Organization.new(params[:organization][:organization])

    if @organization.save
      @organization.users << current_user
      redirect_to organizations_url, :notice => "#{@organization.name} has been created"
    else
      render :new
    end
  end

  def edit
  end

  def update
    @organization = Organization.find(params[:id])
    authorize! :edit, @organization

    if @organization.update_attributes(params[:organization])
      flash[:notice] = "Successfully updated #{@organization.name}."
      if params[:back]
        redirect_to :back
      else
        redirect_to @organization
      end
    else
      flash[:error]= "Failed to update #{@organization.name}."
      if params[:back]
        redirect_to :back
      else
        render :show
      end
    end
  end

  def destroy
  end

  def connect
    @organization = Organization.find(params[:id])
    authorize! :view, @organization
    @fa_user = FA::User.new(params[:fa_user])
    @kits = @organization.available_kits

    if @fa_user.authenticate
      @organization.update_attribute(:fa_member_id, @fa_user.member_id)
      flash[:notice] = "Successfully connected to Fractured Atlas!"
      if params[:back]
        redirect_to :back
      else
        redirect_to @organization
      end
    else
      flash[:error]= "Unable to connect to your Fractured Atlas account."
      if params[:back]
        redirect_to :back
      else
        render :show
      end
    end
  end
  
  def account_history
    @transactions = [
      {:date=>"5/20/2011", :amount=>"-$100.00", :description=>"Donation Disbursal", :account_balance=>"$86.00" },
      {:date=>"5/18/2011", :amount=>"$186.00", :description=>"FAFS Donation", :account_balance=>"$186.00" },
      {:date=>"5/15/2011", :amount=>"-$500.00", :description=>"Deposit to Checking Account", :account_balance=>"$0.00" },
      {:date=>"5/9/2011",  :amount=>"$250.00", :description=>"Earned", :account_balance=>"$600.00" },
      {:date=>"5/8/2011",  :amount=>"$150.00", :description=>"Earned", :account_balance=>"$350.00" },
      {:date=>"5/7/2011",  :amount=>"$200.00", :description=>"Earned", :account_balance=>"$200.00" },       
    ].paginate(:page => params[:page], :per_page => 5)
  end
end