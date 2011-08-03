class ChartsController < ApplicationController
  def index
    authorize! :view, AthenaChart
    @charts = AthenaChart.find_templates_by_organization(current_user.current_organization).sort_by { |chart| chart.name }
  end

  def new
    authorize! :view, AthenaChart
    @chart = AthenaChart.new
  end

  def create
    if params[:chart_id].blank?
      new_chart(params)
    else
      copy_chart(params)
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

  private

  def new_chart(params)
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

  def copy_chart(params)
    @source_chart = AthenaChart.find(params[:chart_id])
    authorize! :view, AthenaChart
    @chart = @source_chart.copy!
    @chart.save
    redirect_to chart_url(@chart)
  end
end