class SearchesController < ApplicationController
  respond_to :html, :json

  def new
    authorize! :manage, Person
    @search = Search.new(params[:search])
    @people = @search.people
    @people = @people.paginate(:page => params[:page], :per_page => 20)
  end

  def create
    authorize! :manage, Person
    @search = Search.new(params[:search])
    @search.organization_id = current_user.current_organization.id
    @search.save!

    redirect_to @search
  end

  def show
    authorize! :manage, Person
    @search = Search.find(params[:id])
    @people = @search.people
    @people = @people.paginate(:page => params[:page], :per_page => 20)
  end
end
