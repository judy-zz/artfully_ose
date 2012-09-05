class SearchesController < ApplicationController

  def new
    authorize! :view, Search
    @search = Search.new(params[:search])
    prepare_search_and_people
  end

  def create
    authorize! :create, Search
    @search = Search.new(params[:search])
    @search.organization_id = current_user.current_organization.id
    @search.save!
    redirect_to @search
  end

  def show
    @search = Search.find(params[:id])
    authorize! :view, @search
    @segment = Segment.new
    session[:return_to] ||= request.referer # Record the current page, in case creating a list segment fails.
    prepare_search_and_people
  end

  private

  def prepare_search_and_people
    @event_options = Event.options_for_select_by_organization(@current_user.current_organization)
    @people = @search.people
    @people = @people.paginate(:page => params[:page], :per_page => 20)
  end
end