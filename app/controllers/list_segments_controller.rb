class ListSegmentsController < ApplicationController
  def index
    @list_segments = ListSegment.find_by_organization_id(current_user.current_organization)
  end

  def show
    @list_segment = ListSegment.find(params[:id])
  end

  def new
    @list_segment = ListSegment.new
    @list_segment.people = find_people
  end

  def create
    @list_segment = ListSegment.new(params[:list_segment])
    @list_segment.organization = current_user.current_organization
    @list_segment.people = find_people
    if @list_segment.save
      redirect_to @list_segment
    else
      render :new
    end
  end

  private

  def find_people
    params[:people].collect { |person_id| AthenaPerson.find(person_id) }.tap do |people|
      people.each do |person|
        authorize! :view, person
      end
    end
  end
end