class ChartsController < ApplicationController
  def index
    authorize! :view, Chart
    @charts = current_organization.charts.template
  end

  def new
    authorize! :view, Chart
    @chart = current_organization.charts.build(params[:chart])
  end

  def create
    if params[:chart_id].blank?
      new_chart(params)
    else
      copy_chart(params)
    end
  end

  def show
    @charts = current_organization.charts.template
    @chart = Chart.find(params[:id])
    authorize! :view, @chart
  end

  def edit
    @chart = Chart.find(params[:id])
    authorize! :edit, @chart
  end

  def update
    @chart = Chart.find(params[:id])
    authorize! :edit, @chart
    @chart.update_attributes(params[:athena_chart][:athena_chart])
    if @chart.save
      redirect_to chart_url(@chart)
    else
      render :edit and return
    end
  end

  def destroy
    @chart = Chart.find(params[:id])
    authorize! :destroy, @chart
    @chart.destroy
    redirect_to charts_url
  end

  private

  def new_chart(params)
    @chart = Chart.new
    @chart.update_attributes(params[:athena_chart][:athena_chart])
    @chart.organization_id = current_user.current_organization.id
    @chart.isTemplate = true

    if @chart.save
      redirect_to chart_url(@chart)
    else
      render :new
    end
  end

  def copy_chart(params)
    @source_chart = Chart.find(params[:chart_id])
    authorize! :view, Chart
    @chart = @source_chart.copy!
    @chart.save
    redirect_to chart_url(@chart)
  end
end