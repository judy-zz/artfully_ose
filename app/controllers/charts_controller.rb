class ChartsController < ApplicationController
  def new
    @chart = AthenaChart.new
    @event = AthenaEvent.find(params[:event_id])
    @chart.name = build_default_chart_name(@event)
  end

  def create
    @chart = AthenaChart.new
    @event = AthenaEvent.find(params[:event_id])
    @chart.update_attributes(params[:athena_chart][:athena_chart])
    if @chart.save
      @event.chartId=@chart.id
      @event.save
      redirect_to event_url(@event)
    else
      render :template => 'chart/new'
    end
  end
  
  def show
    @chart = AthenaChart.find(params[:id])
    @chart.event = AthenaEvent.find(params[:event_id])
  end 

  def edit
    @chart = AthenaChart.find(params[:id])
    @event = AthenaEvent.find(params[:event_id])
  end

  def update
    @chart = AthenaChart.find(params[:id])    
    @chart.update_attributes(params[:athena_chart][:athena_chart])
    if @chart.save
      @chart.event = AthenaEvent.find(params[:event_id])
      redirect_to event_url(@chart.event)
    else
      render :edit and return
    end
  end   
  
  private 
    def build_default_chart_name(event)
      default_name = event.name
      if event.chart.nil?
        default_name += ', default seating chart'
      end
      default_name
    end
end