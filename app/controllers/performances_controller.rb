class PerformancesController < ApplicationController

  before_filter :authenticate_user!, :except => [:show ]

  def index
    @performances = Performance.all
  end
  
  def new
    @performance = Performance.new
  end

  def create
    @performance = Performance.create(params[:performance])
    if @performance.valid?
      Ticket.generate_for_performance(@performance, params[:seats], params[:price])
      @performance.user = current_user
      @performance.save
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
    @tickets = Ticket.find_by_performance(@performance)
  end
end
