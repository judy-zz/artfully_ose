class DiscountsController < ApplicationController
  before_filter :authorize_event

  def index
    @discounts = @event.discounts
  end

  def new
    @discount = @event.discounts.build
  end

  def edit
    @discount = Discount.find(params[:id])
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

  def update
    @discount = Discount.find(params[:id])

    if @discount.update_attributes(params[:discount])
      flash[:success] = "Discount #{@discount.code} updated successfully."
      redirect_to event_discounts_path(@event)
    else
      render :edit
    end
  end

private

  def authorize_event
    @event = Event.find params[:event_id]
    authorize! :edit, @event
  end
end
