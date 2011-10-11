class SectionsController < ApplicationController
  def new
    @section = Section.new
    @chart = Chart.find(params[:chart_id])
  end

  def create
    @section = Section.new

    @section.update_attributes(params[:athena_section][:athena_section])
    @chart = Chart.find(params[:chart_id])
    @section.chart_id = @chart.id

    if @section.save
      redirect_to chart_url(@chart)
    else
      render :template => 'sections/new'
    end
  end

  def edit
    @section = Section.find(params[:id])
    @chart = Chart.find(params[:chart_id])
  end

  def update
    @section = Section.find(params[:id])
    @section.update_attributes(params[:athena_section][:athena_section])
    @chart = Chart.find(params[:chart_id])
    @section.chart_id = @chart.id

    if @section.save
      redirect_to chart_url(@chart)
    else
      render :template => 'sections/edit'
    end
  end

  def destroy
    @section = Section.find(params[:id])
    @section.destroy
    @chart = Chart.find(params[:chart_id])
    redirect_to chart_url(@chart)
  end

end