class SectionsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @section = AthenaSection.new
    @chart = AthenaChart.find(params[:chart_id])
  end

  def create
    @section = AthenaSection.new

    @section.update_attributes(params[:athena_section][:athena_section])
    @chart = AthenaChart.find(params[:chart_id])
    @section.chart_id = @chart.id

    if @section.save
      redirect_to chart_url(@chart)
    else
      render :template => 'sections/new'
    end
  end

  def edit
    @section = AthenaSection.find(params[:id])
    @chart = AthenaChart.find(params[:chart_id])
  end

  def update
    @section = AthenaSection.find(params[:id])
    @section.update_attributes(params[:athena_section][:athena_section])
    @chart = AthenaChart.find(params[:chart_id])
    @section.chart_id = @chart.id

    if @section.save
      redirect_to chart_url(@chart)
    else
      render :template => 'sections/edit'
    end
  end

  def destroy
    @section = AthenaSection.find(params[:id])
    @section.destroy
    @chart = AthenaChart.find(params[:chart_id])
    redirect_to chart_url(@chart)
  end

end