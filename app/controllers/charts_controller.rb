class ChartsController < ApplicationController
  before_filter :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  def index
    @charts = AthenaChart.find_templates_by_organization(current_user.current_organization).sort_by { |chart| chart.name }
    authorize! :view, AthenaChart
  end

  def new
    @chart = AthenaChart.new
  end

  def create
    @chart = AthenaChart.new
    @chart.update_attributes(params[:athena_chart][:athena_chart])
    @chart.organization_id = current_user.current_organization.id
    @chart.isTemplate = true

    if @chart.save
      redirect_to chart_url(@chart)
    else
      render :new
    end
  end

  def show
    @charts = AthenaChart.find_templates_by_organization(current_user.current_organization).sort_by { |chart| chart.name }
    @chart = AthenaChart.find(params[:id])
    authorize! :view, @chart
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