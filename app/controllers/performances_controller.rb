class PerformancesController < ApplicationController
  def index
    @performances = Performance.all
  end
  
  def new
    @performance = Performance.new
  end

  def create
    @performance = Performance.create(params[:performance])
    if @performance.save
      Ticket.generate_for_performance(@performance, params[:seats], params[:price])
      redirect_to(@performance, :notice => 'Created a new performance.')
    else
      render :action => "new"
    end
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
