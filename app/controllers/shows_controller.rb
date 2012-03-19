class ShowsController < ApplicationController
  before_filter :find_event, :only => [ :index, :show, :new, :edit ]
  before_filter :check_for_charts, :only => [ :index, :new ]
  before_filter :upcoming_shows, :only => [ :index, :show ]

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to event_url(@show.event)
  end

  def index
    authorize :manage, @event
    @shows = @event.shows.paginate(:page => params[:page], :per_page => 10)
    @next_show = @event.next_show
  end

  def duplicate
    @show = Show.find(params[:id])
    authorize! :duplicate, @show

    @new_show = @show.dup!
    @new_show.save
    redirect_to event_path(@show.event)
  end

  def new
    @show = @event.next_show
  end

  def create
    @event = Event.find(params[:event_id])
    @show = @event.shows.build(params[:show].merge(:organization => current_organization))
    @show.datetime = ActiveSupport::TimeZone.create(@event.time_zone).parse(params[:show][:datetime])

    if @show.save
      flash[:notice] = "Show created on #{l @show.datetime_local_to_event, :format => :date_at_time}"
      redirect_to event_path(@event)
    else
      flash[:error] = "There was a problem creating your show."
      render :new
    end
  end

  def show
    @show = Show.find(params[:id])
    authorize! :view, @show

    @show.tickets = @show.tickets
    @tickets = @show.tickets
  end

  def edit
    @show = Show.find(params[:id])
    authorize! :edit, @show
  end

  def update
    @show = Show.find(params[:id])
    authorize! :edit, @show
    if @show.live?
      flash[:alert] = 'Tickets have already been created for this performance'
      redirect_to event_url(@performance.event) and return
    else
      @show.datetime = ActiveSupport::TimeZone.create(@show.event.time_zone).parse(params[:show][:datetime])
      @show.chart_id = params[:show][:chart_id]
      if @show.save
        redirect_to event_path(@show.event)
      else
        flash[:alert] = 'This performance cannot be edited'
        render :edit
      end
    end
  end

  def destroy
    @show = Show.find(params[:id])
    authorize! :destroy, @show

    if @show.destroy
      render :nothing => true, :status => 204 and return  
    else
      render :status => :forbidden and return
    end
  end

  def door_list
    @show = Show.find(params[:id])
    @event = @show.event
    authorize! :view, @show
    @current_time = DateTime.now.in_time_zone(@show.event.time_zone)
    @door_list = DoorList.new(@show)

    respond_to do |format|
      format.html

      format.csv do
        @filename = [ @event.name, @show.datetime_local_to_event.to_s(:db_date), "door-list.csv" ].join("-")
        @csv_string = @door_list.items.to_comma
        send_data @csv_string, :filename => @filename, :type => "text/csv", :disposition => "attachment"
      end
    end
  end

  def published
    @show = Show.find(params[:show_id])
    authorize! :show, @show

    if @show.tickets.empty?
      respond_to do |format|
        format.html do
          flash[:error] = 'Please create tickets for this show before putting it on sale'
          redirect_to event_show_url(@show.event, @show)
        end

        format.json { render :json => { :errors => ['Please create tickets for this show before putting it on sale'] } }
      end

      return
    end

    with_confirmation do
      @show.publish!
      respond_to do |format|
        format.html { redirect_to event_show_url(@show.event, @show), :notice => 'Your show is now published.' }
        format.json { render :json => @show.as_json.merge('glance' => @show.glance.as_json) }
      end
    end
  end

  def unpublished
    @show = Show.find(params[:show_id])
    authorize! :hide, @show

    with_confirmation do
      @show.unpublish!
      respond_to do |format|
        format.html { redirect_to event_show_url(@show.event, @show), :notice => 'Your show is now unpublished.' }
        format.json { render :json => @show.as_json.merge('glance' => @show.glance.as_json) }
      end
    end
  end

  def built
    @show = Show.find(params[:show_id])
    authorize! :edit, @show

    @event = @show.event
    # TODO: The ability to create tickets is business logic, not authorization logic.
    authorize! :create_tickets, @show.chart.sections

    @show.build!

    respond_to do |format|
      format.html { redirect_to event_show_url(@event, @show) }
      format.json { render :json => @show.as_json.merge('glance' => @show.glance.as_json) }
    end
  end

  def on_sale
    authorize! :bulk_edit, Ticket
    with_confirmation do
      @show = Show.find(params[:show_id])

      if @show.bulk_on_sale(:all)
        @show.publish!
        notice = "Put all tickets on sale."
      else
        error = "Tickets that have been sold or comped can't be put on or taken off sale. A ticket that is already on sale or off sale can't be put on or off sale again."
      end

      respond_to do |format|
        format.html do
          flash[:notice] = notice
          flash[:error] = error
          redirect_to event_show_url(@show.event, @show)
        end

        format.json do
          if error.blank?
            render :json => @show.as_json.merge('glance' => @show.glance.as_json)
          else
            render :json => { :errors => [ error ] }, :status => 409
          end
        end

      end
    end
  end

  private
    def find_event
      @event = Event.find(params[:event_id])
    end

    def upcoming_shows
      @upcoming = @event.upcoming_shows
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

    def check_for_charts
      if @event.charts.empty?
         flash[:error] = "Please import a chart to this event before working with shows."
         redirect_to event_path(@event)
      end
    end

end
