class ChartsController < ApplicationController
  def index
    @charts = AthenaChart.find_by_producer(current_user.athena_id).sort_by { |chart| chart.name }
  end
  
  def new
    @chart = AthenaChart.new
  end

  def create
    @chart = AthenaChart.new
    @chart.update_attributes(params[:athena_chart][:athena_chart])
    @chart.producer_pid = current_user.athena_id
     
    if @chart.save
      redirect_to chart_url(@chart)
    else
      render :new
    end
  end
  
  def show
    @chart = AthenaChart.find(params[:id])
  end

  def edit
    @chart = AthenaChart.find(params[:id])
  end

  def update
    @chart = AthenaChart.find(params[:id])
    @chart.update_attributes(params[:athena_chart][:athena_chart])
    if @chart.save
      redirect_to chart_url(@chart)
    else
      render :edit and return
    end
  end
  
  def destroy
    @chart = AthenaChart.find(params[:id])
    @chart.destroy
    redirect_to charts_url
  end
  
  def duplicate
    @chart = AthenaChart.find(params[:athena_chart][:id])
    @event = AthenaEvent.find(params[:event_id])
    @new_chart = @chart.dup!
    @new_chart.event_id = @event.id
    @new_chart.save
    redirect_to event_url(@new_chart.event_id)
  end
end