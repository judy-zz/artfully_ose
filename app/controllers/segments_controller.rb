class SegmentsController < ApplicationController
  def index
    authorize! :view, Segment
    @segments = current_organization.segments
  end

  def show
    @segment = Segment.find(params[:id])
    authorize! :view, @segment
    respond_to do |format|
      format.html
      format.csv { render :csv => @segment.people, :filename => "#{@segment.name}-#{DateTime.now.strftime("%m-%d-%y")}.csv" }
    end
  end

  def new
    authorize! :create, Segment
    @segment = current_organization.segments.build(params[:segment])
  end

  def create
    authorize! :create, Segment
    @segment = current_organization.segments.build(params[:segment])
    if @segment.save
      redirect_to @segment
    else
      render :new
    end
  end
end