class ChartsController < ApplicationController
  def new
    @event = AthenaEvent.find(params[:event_id])
    @chart = AthenaChart.default_chart_for(@event)
    @charts= AthenaChart.find_by_producer(current_user.athena_id)
  end

  def create
    @event = AthenaEvent.find(params[:event_id])

    #If an id was sent, they want to duplicate the sections from an existing chart
    if params[:athena_chart][:athena_chart][:id].blank?
      @chart = AthenaChart.new
    else
      @source_chart = AthenaChart.find(params[:athena_chart][:athena_chart][:id])
      @chart = @source_chart.dup!
    end
    #can't use update_attributes here because it'll pick up the blank :id
    @chart.name = params[:athena_chart][:athena_chart][:name]
    @chart.event_id = @event.id
    @chart.producer_pid = current_user.athena_id
    if @chart.save
      @event.chartId=@chart.id
      @event.save
      redirect_to event_url(@event)
    else
      render :new
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
end