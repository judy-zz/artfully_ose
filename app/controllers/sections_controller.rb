class SectionsController < ApplicationController
  before_filter :find_chart, :except => [:on_sale, :off_sale]

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
  
  def on_sale
    @qty = params[:quantity].to_i
    @section = Section.find(params[:id])
    @section.put_on_sale @qty
    flash[:notice] = "Tickets in section #{@section.name} are now on sale"
    redirect_to event_show_path(@section.chart.show.event, @section.chart.show)
  end
  
  def off_sale
    @qty = params[:quantity].to_i
    @section = Section.find(params[:id])
    @section.take_off_sale @qty
    flash[:notice] = "Tickets in section #{@section.name} are now off sale"
    redirect_to event_show_path(@section.chart.show.event, @section.chart.show)
  end

  private

    def find_chart
      @chart = Chart.find(params[:chart_id])
    end

end