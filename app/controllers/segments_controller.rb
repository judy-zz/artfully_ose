class SegmentsController < ApplicationController
  def index
    @segments = Segment.find_by_organization_id(current_user.current_organization)
  end

  def show
    @segment = Segment.find(params[:id])
    respond_to do |format|
      format.html
      format.csv { render :csv => @segment.people, :filename => "#{@segment.name}-#{DateTime.now.strftime("%m-%d-%y")}.csv" }
    end
  end

  def new
    @segment = Segment.new(params[:segment])
    @segment.organization = current_user.current_organization
  end

  def create
    @segment = Segment.new(params[:segment])
    @segment.organization = current_user.current_organization
    if @segment.save
      redirect_to @segment
    else
      render :new
    end
  end
end