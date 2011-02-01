class ChartsController < ApplicationController
  before_filter :authenticate_user!, :except => [ :show ]

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  def index
    @charts = AthenaChart.find_templates_by_producer(current_user.athena_id).sort_by { |chart| chart.name }
    authorize! :view, AthenaChart
  end

  def new
    @chart = AthenaChart.new
  end

  def create
    @chart = AthenaChart.new
    @chart.update_attributes(params[:athena_chart][:athena_chart])
    @chart.producer_pid = current_user.athena_id
    @chart.isTemplate = true

    if @chart.save
      redirect_to chart_url(@chart)
    else
      render :new
    end
  end

  def show
    @chart = AthenaChart.find(params[:id])
    authorize! :view, @chart
    respond_to do |format|
      format.html
      format.jsonp  { render_jsonp @chart.to_json }
    end
  end

  def edit
    @chart = AthenaChart.find(params[:id])
    authorize! :edit, AthenaChart
  end

  def update
    @chart = AthenaChart.find(params[:id])
    authorize! :edit, AthenaChart
    @chart.update_attributes(params[:athena_chart][:athena_chart])
    if @chart.save
      redirect_to chart_url(@chart)
    else
      render :edit and return
    end
  end

  def destroy
    @chart = AthenaChart.find(params[:id])
    authorize! :destroy, AthenaChart
    @chart.destroy
    redirect_to charts_url
  end

  def assign
    @event = AthenaEvent.find(params[:event_id])

    if params[:athena_chart].nil?
      flash[:error] = "Please create a chart to import to this event."
    else
      @chart = AthenaChart.find(params[:athena_chart][:id])
      @chart.assign_to(@event)
    end
    redirect_to event_url(@event)
  end
end