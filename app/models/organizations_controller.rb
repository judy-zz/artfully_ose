class OrganizationsController < ApplicationController

  before_filter :already_in?, :only => [ :new, :create ]

  def index
    @organization = current_user.organization || Organization.new
  end

  def show
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

  private
    def already_in?
      unless current_user.organization.nil?
        flash[:error] = "You are already part of an organization"
        redirect_to organizations_url
      end
    end
end