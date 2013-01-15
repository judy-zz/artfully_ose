class DiscountsController < ApplicationController
  before_filter :authorize_event
  before_filter :grab_section_names, :only => [:new, :edit]

  def index
    @discounts = @event.discounts
  end

  def new
    @discount = Discount.new(:event => @event)
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

  def destroy
    @discount = Discount.find(params[:id])

    if @discount.destroy
      flash[:success] = "Discount #{@discount.code} was deleted."
    else
      flash[:error] = "Discount #{@discount.code} was not deleted."
    end

    redirect_to event_discounts_path(@event)
  end

private

  def authorize_event
    @event = Event.find params[:event_id]
    authorize! :edit, @event
  end

  def grab_section_names
    @section_names = @event.charts.collect{|c| c.sections.collect{|s| s.name}}.flatten.uniq.sort
  end
end
