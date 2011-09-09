class BoxOfficesController < ApplicationController
  def show
    @event = AthenaEvent.find(params[:event_id])
    @show = AthenaPerformance.find(params[:show_id])
    authorize! :view, @show
    @door_list = DoorList.new(@show)
  end
end