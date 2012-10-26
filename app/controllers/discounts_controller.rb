class DiscountsController < ApplicationController
  def index
    @event = Event.find params[:event_id]
    authorize! :edit, @event
    @discounts = @event.discounts
  end
end
