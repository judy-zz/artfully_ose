class SectionsController < ApplicationController
  
  def new
    @section = AthenaSection.new
    @event = AthenaEvent.find(params[:event_id])
    @chart = AthenaChart.find(params[:chart_id])
  end
  
  def create
    @section = AthenaSection.new
    
    @section.update_attributes(params[:athena_section][:athena_section])
    @event = AthenaEvent.find(params[:event_id])
    @chart = AthenaChart.find(params[:chart_id])
    @section.chartId=@chart.id
    
    if @section.save
      redirect_to event_url(@event)
    else
      render :template => 'events/new'
    end
  end

end