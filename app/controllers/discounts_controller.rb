class DiscountsController < ApplicationController
  before_filter :authorize_event

  def index
    @discounts = @event.discounts
  end

  def new
    @discount = @event.discounts.build
  end

  def create
    @discount = @event.discounts.build(params[:discount])
    @discount.creator = current_user

    if @discount.save
      flash[:success] = "Discount #{@discount.code} created successfully."
      redirect_to event_discounts_path(@event)
    else
      render :new
    end
  end

private

  def authorize_event
    @event = Event.find params[:event_id]
    authorize! :edit, @event
  end
end
