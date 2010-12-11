class ChartsController < ApplicationController
  def index
    @charts = AthenaChart.find_by_producer(current_user.athena_id)
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
end