class ChartsController < ApplicationController
  def index
    authorize! :view, AthenaChart
    @charts = AthenaChart.find_templates_by_organization(current_user.current_organization).sort_by { |chart| chart.name }
  end

  def new
    authorize! :view, AthenaChart
    @chart = AthenaChart.new
  end

  def copy
    @source_chart = AthenaChart.find(params[:chart_id])
    authorize! :view, AthenaChart
    @chart = @source_chart.copy!
    @chart.save
    redirect_to chart_url(@chart) and return
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
    authorize! :edit, @chart
  end

  def update
    @chart = AthenaChart.find(params[:id])
    authorize! :edit, @chart
    @chart.update_attributes(params[:athena_chart][:athena_chart])
    if @chart.save
      redirect_to chart_url(@chart)
    else
      render :edit and return
    end
  end

  def destroy
    @chart = AthenaChart.find(params[:id])
    authorize! :destroy, @chart
    @chart.destroy
    redirect_to charts_url
  end

  def assign
    @event = AthenaEvent.find(params[:event_id])

    if params[:athena_chart].nil?
      flash[:error] = "Please create a chart to import to this event."
    else
      @chart = AthenaChart.find(params[:athena_chart][:id])
      unless "true" == @event.is_free
        @chart.assign_to(@event)
      else
        num_paid_sections = @chart.sections.drop_while{|s| s.price.to_i == 0}.length
        if num_paid_sections > 0
          flash[:alert] = "Cannot add chart with paid sections to a FREE event"
        else
          @chart.assign_to(@event)
        end
      end
    end
    redirect_to event_url(@event)
  end
end