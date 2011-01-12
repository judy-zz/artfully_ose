class PerformancesController < ApplicationController
  before_filter :authenticate_user!

  def duplicate
    @performance = AthenaPerformance.find(params[:id])
    @new_performance = @performance.dup!
    @new_performance.save
    redirect_to event_url(@new_performance.event_id)
  end

  def new
    @performance = AthenaPerformance.new
    @event = AthenaEvent.find(params[:event_id])
    @charts = AthenaChart.find_by_event(@event)
    if @charts.empty?
       flash[:error] = "Please import a chart to this event before creating a new performance."
       redirect_to event_url(@event)
    end
    @performance.event_id=@event.id
    @performance.chart_id=nil 
  end

  def create
    @performance = AthenaPerformance.new
    @event = AthenaEvent.find(params[:event_id])
    @performance.update_attributes(params[:athena_performance][:athena_performance])
    @performance.event_id=@event.id
    @performance.tickets_created = 'false'
    if @performance.save
      redirect_to event_url(@performance.event)
    else
      render :template => 'performances/new'
    end
  end

  def show
    @performance = AthenaPerformance.find(params[:id])
    @event = AthenaEvent.find(@performance.event_id)
    @tickets = AthenaTicket.find(:all, :params => { :performanceId => "eq#{@performance.id}" })
    @tickets = @tickets.sort_by { |ticket| ticket.price }
    @tickets_sold = @tickets.select { |ticket| ticket.sold? }
    @gross_potential = 0
    @gross_sales = 0
    @tickets.each { |ticket| @gross_potential += ticket.price.to_i}
    @tickets.each { |ticket| @gross_sales += ticket.price.to_i if ticket.sold?}
    respond_to do |format|
      format.html
      format.widget
    end
  end

  def edit
    @performance = AthenaPerformance.find(params[:id])
    @event = AthenaEvent.find(params[:event_id])
    @charts = AthenaChart.find_by_event(@event)
  end

  def update
    @performance = AthenaPerformance.find(params[:id])
    @performance.update_attributes(params[:athena_performance][:athena_performance])
    if @performance.save
      redirect_to event_url(@performance.event)
    else
      render :template => 'performances/new'
    end
  end

  def destroy
    @performance = AthenaPerformance.find(params[:id])

    if @performance.tickets_created?
      flash[:notice] = 'Tickets have already been created.'
    else
      @performance.destroy
    end

    redirect_to event_url(@performance.event)
  end

  def createtickets
    @performance = AthenaPerformance.find(params[:id])
    AthenaTicketFactory.for_performance(@performance)
    @event = AthenaEvent.find(@performance.event_id)
    @charts = AthenaChart.find_by_event(@event)
    redirect_to performance_url(@performance)
  end
end