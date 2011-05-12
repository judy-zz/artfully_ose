class PerformancesController < ApplicationController
  before_filter :find_event, :only => [ :index, :show ]
  before_filter :upcoming_performances, :only => [ :index, :show ]

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to event_url(@performance.event)
  end

  def index
    @performances = @event.performances.paginate(:page => params[:page], :per_page => 10)
    @performance = @event.next_perf
  end

  def duplicate
    @performance = AthenaPerformance.find(params[:id])
    authorize! :duplicate, @performance

    @new_performance = @performance.dup!
    @new_performance.save
    redirect_to event_performances_path(@performance.event)
  end

  def new
    @event = AthenaEvent.find(params[:event_id])
    @performance = @event.next_perf

    if @event.charts.empty?
       flash[:error] = "Please import a chart to this event before creating a new performance."
       redirect_to event_path(@performance.event) 
    end
  end

  def create
    @performance = AthenaPerformance.new
    @event = AthenaEvent.find(params[:event_id])
    @performance.event = @event

    @performance.update_attributes(params[:athena_performance])
    @performance.organization_id = current_user.current_organization.id

    if @performance.valid? && @performance.save
      flash[:notice] = "Performance created on #{l @performance.datetime.in_time_zone(@performance.time_zone), :format => :date_at_time}"
      redirect_to event_performances_path(@performance.event) 
    else
      redirect_to event_performances_path(@performance.event) 
    end
  end

  def show
    @performance = AthenaPerformance.find(params[:id])
    authorize! :view, @performance
    @performance.datetime = @performance.datetime.in_time_zone(@event.time_zone)

    @performance.tickets = @performance.tickets
    @tickets = @performance.tickets.paginate(:page => params[:page], :per_page => 25)
  end

  def edit
    @performance = AthenaPerformance.find(params[:id])
    authorize! :edit, @performance
  end

  def update
    @performance = AthenaPerformance.find(params[:id])
    authorize! :edit, @performance

    without_tickets do
      @performance.update_attributes(params[:athena_performance])
      if @performance.save
        redirect_to event_performances_path(@performance.event)
      else
        render :template => 'performances/new'
      end
    end
  end

  def destroy
    @performance = AthenaPerformance.find(params[:id])
    authorize! :destroy, @performance

    @performance.destroy
    redirect_to event_url(@performance.event)
  end

  def door_list
    @performance = AthenaPerformance.find(params[:id])
    authorize! :view, @performance
    @door_list = DoorList.new(@performance)
  end

  def put_on_sale
    @performance = AthenaPerformance.find(params[:id])
    authorize! :put_on_sale, @performance

    if @performance.tickets.empty?
      flash[:error] = 'Please create tickets for this performance before putting it on sale'
      redirect_to event_performance_url(@performance.event, @performance) and return
    end

    with_confirmation do
      @performance.put_on_sale!
      flash[:notice] = 'Your performance is on sale in the widget!'
      redirect_to event_performance_url(@performance.event, @performance) and return
    end
  end

  def take_off_sale
    @performance = AthenaPerformance.find(params[:id])
    authorize! :take_off_sale, @performance
    with_confirmation do
      @performance.take_off_sale!
      flash[:notice] = 'Your performance has been taken off sale from the widget!'
      redirect_to event_performance_url(@performance.event, @performance) and return
    end
  end

  def createtickets
    @performance = AthenaPerformance.find(params[:id])
    authorize! :edit, @performance

    AthenaTicketFactory.for_performance(@performance)
    @event = AthenaEvent.find(@performance.event_id)
    @charts = AthenaChart.find_by_event(@event)
    redirect_to event_performance_url(@event, @performance)
  end

  private
    def find_event
      @event = AthenaEvent.find(params[:event_id])
    end

    def upcoming_performances
      @upcoming = @event.upcoming_performances
    end

    def with_confirmation
      if params[:confirm].nil?
        flash[:info] = "Please confirm your changes before we save them."
        render params[:action] + '_confirm' and return
      else
        yield
      end
    end

    def without_tickets
      if @performance.tickets_created?
        flash[:alert] = 'Tickets have already been created for this performance'
        redirect_to event_url(@performance.event) and return
      else
        yield
      end
    end
end