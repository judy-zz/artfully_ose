class PerformancesController < ApplicationController
  def index
    @performances = Performance.all
  end
  
  def new
    @performance = Performance.new
  end

  def create
    @performance = Performance.create(params[:performance])
    redirect_to(@performance, :notice => 'Performance was successfully created!')
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def show
    @performance = Performance.find(params[:id])
  end
end
