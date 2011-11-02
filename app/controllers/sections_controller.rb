class SectionsController < ApplicationController
  before_filter :find_chart

  def new
    @section = Section.new
  end

  def create
    @section = Section.new

    @section.update_attributes(params[:section])
    @section.chart_id = @chart.id

    if @section.save
      redirect_to chart_url(@chart)
    else
      render :template => 'sections/new'
    end
  end

  def edit
    @section = Section.find(params[:id])
  end

  def update
    @section = Section.find(params[:id])
    @section.update_attributes(params[:section])
    @section.chart_id = @chart.id

    if @section.save
      redirect_to @chart
    else
      render :template => 'sections/edit'
    end
  end

  def destroy
    @section = Section.find(params[:id])
    @section.destroy
    redirect_to @chart
  end

  private

  def find_chart
    @chart = Chart.find(params[:chart_id])
  end

end