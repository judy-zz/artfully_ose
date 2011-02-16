class OrganizationsController < ApplicationController

  def index
    @organizations = current_user.organizations || []
  end

  def show
    @organization = Organization.find(params[:id])
    @kits = @organization.kits
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(params[:organization])
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
  end

  def destroy
  end
end