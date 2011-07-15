class PerformancesController < ApplicationController
  before_filter :find_event, :only => [ :index, :show, :new ]
  before_filter :check_for_charts, :only => [ :index, :new ]
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
    @performance = @event.next_perf
  end

  def create
    @performance = AthenaPerformance.new
    @event = AthenaEvent.find(params[:event_id])
    @performance.event = @event

    @performance.update_attributes(params[:athena_performance])
    @performance.organization_id = current_user.current_organization.id

    if @performance.valid? && @performance.save
      flash[:notice] = "Performance created on #{l @performance.datetime, :format => :date_at_time}"
      redirect_to event_performances_path(@performance.event)
    else
      flash[:error] = "There was a problem creating your performance."
      redirect_to event_performances_path(@performance.event)
    end
  end

  def show
    @performance = AthenaPerformance.find(params[:id])
    authorize! :view, @performance

    @performance.tickets = @performance.tickets
    @tickets = @performance.tickets
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
    @current_time = DateTime.now.in_time_zone(@performance.event.time_zone)
    @door_list = DoorList.new(@performance)
  end

  def published
    @performance = AthenaPerformance.find(params[:performance_id])
    authorize! :show, @performance

    if @performance.tickets.empty?
      respond_to do |format|
        format.html do
          flash[:error] = 'Please create tickets for this performance before putting it on sale'
          redirect_to event_performance_url(@performance.event, @performance)
        end

        format.json { render :json => { :errors => ['Please create tickets for this performance before putting it on sale'] } }
      end

      return
    end

    with_confirmation do
      @performance.publish!
      respond_to do |format|
        format.html { redirect_to event_performance_url(@performance.event, @performance), :notice => 'Your performance is now published.' }
        format.json { render :json => @performance.as_json.merge('glance' => @performance.glance.as_json) }
      end
    end
  end

  def unpublished
    @performance = AthenaPerformance.find(params[:performance_id])
    authorize! :hide, @performance

    with_confirmation do
      @performance.unpublish!
      respond_to do |format|
        format.html { redirect_to event_performance_url(@performance.event, @performance), :notice => 'Your performance is now unpublished.' }
        format.json { render :json => @performance.as_json.merge('glance' => @performance.glance.as_json) }
      end
    end
  end

  def built
    @performance = AthenaPerformance.find(params[:performance_id])
    authorize! :edit, @performance

    AthenaTicketFactory.for_performance(@performance)
    @event = AthenaEvent.find(@performance.event_id)
    authorize! :create_tickets, @performance.chart.sections

    respond_to do |format|
      format.html { redirect_to event_performance_url(@event, @performance) }
      format.json { render :json => @performance.as_json.merge('glance' => @performance.glance.as_json) }
    end
  end

  def on_sale
    authorize! :bulk_edit, AthenaTicket
    with_confirmation do
      @performance = AthenaPerformance.find(params[:performance_id])

      if @performance.bulk_on_sale(:all)
        @performance.publish!
        notice = "Put all tickets on sale."
      else
        error = "Tickets that have been sold or comped can't be put on or taken off sale. A ticket that is already on sale or off sale can't be put on or off sale again."
      end

      respond_to do |format|
        format.html do
          flash[:notice] = notice
          flash[:error] = error
          redirect_to event_performance_url(@performance.event, @performance)
        end

        format.json do
          if error.blank?
            render :json => @performance.as_json.merge('glance' => @performance.glance.as_json)
          else
            render :json => { :errors => [ error ] }, :status => 409
          end
        end

      end
    end
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
        respond_to do |format|
          format.html { render params[:action] + '_confirm' and return }
          format.json { render :json => { :errors => [ "Confirmation is required before you can proceed." ] }, :status => 400 }
        end
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

    def check_for_charts
      if @event.charts.empty?
         flash[:error] = "Please import a chart to this event before working with performances."
         redirect_to event_path(@event)
      end
    end

end