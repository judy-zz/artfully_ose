class EventsController < ApplicationController
  def create
    @event = AthenaEvent.new

    @event.update_attributes(params[:athena_event][:athena_event])
    @event.producer_pid = current_user.athena_id
    if @event.save
      redirect_to event_url(@event)
    else
      render :template => 'events/new'
    end
  end

  def index
    user = params[:user_id].blank?? current_user : User.find(params[:user_id])
    @events = AthenaEvent.find(:all, :params => { :producerPid => 'eq' + user.athena_id })

    respond_to do |format|
      format.html
      format.jsonp  { render_jsonp (@events.to_json) }
    end
  end

  def show
    @event = AthenaEvent.find(params[:id])
    @event.performances= AthenaPerformance.find(:all, :params => { :eventId => "eq#{@event.id}" })
    @event.charts= AthenaChart.find(:all, :params => { :eventId => "eq#{@event.id}" })

    if user_signed_in?
      @charts = AthenaChart.find_templates_by_producer(current_user.athena_id).sort_by { |chart| chart.name }
      @chart = AthenaChart.new
    end

    respond_to do |format|
      format.html
      format.jsonp  { render_jsonp (@event.to_json) }
    end
  end

  def new
    @event = AthenaEvent.new
  end

  def edit
    @event = AthenaEvent.find(params[:id])
  end

  def update
    @event = AthenaEvent.find(params[:id])

    @event.update_attributes(params[:athena_event][:athena_event])
    if @event.save
      redirect_to event_url(@event)
    else
      render :edit and return
    end
  end
end
