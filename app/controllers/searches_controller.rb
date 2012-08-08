class SearchesController < ApplicationController

  def new
    @search = Search.new(params[:search])
    prepare_search_and_people
  end

  def create
    @search = Search.new(params[:search])
    @search.organization_id = current_user.current_organization.id
    @search.save!
    redirect_to @search
  end

  def show
    @search = Search.find(params[:id])
    @segment = Segment.new
    prepare_search_and_people
  end

  private

  def prepare_search_and_people
    @event_options = Event.options_for_select_by_organization(@current_user.current_organization)
    @people = @search.people
    @people = @people.paginate(:page => params[:page], :per_page => 20)
  end
end
