class SalesController < ApplicationController
  before_filter :find_event, :find_show, :find_people, :create_door_list, :find_dummy

  def show
    redirect_to new_event_show_sales_path(@event, @show)
  end

  def new
    @sale = Sale.new(@show, @show.chart.sections)
    setup_defaults
  end

  def create
    @sale = Sale.new(@show, @show.chart.sections, params[:quantities])

    if @sale.sell(payment)
      redirect_to new_event_show_sales_path(@event, @show), :notice => "Sold #{@sale.tickets.length} tickets"
    else
      flash[:error] = "#{@sale.errors.full_messages.to_sentence.capitalize}."
      render :new
    end
  end

  private

  def setup_defaults
    params[:anonymous]   = true
    params[:cash]        = true
    params[:credit_card] = {}
  end

  def find_event
    @event = Event.find(params[:event_id])
  end

  def find_show
    @show = Show.find(params[:show_id])
    authorize! :view, @show
  end

  def find_people
    if params[:terms].present?
      @people = Person.search_index(params[:terms].dup, current_user.current_organization)
    else
      @people = []
    end
  end

  def create_door_list
    @door_list = DoorList.new(@show)
  end

  def find_dummy
    @dummy = Person.dummy_for(current_user.current_organization)
  end

  def person
    Person.find(params[:person_id])
  end

  def payment
    if has_card_info?
      card = AthenaCreditCard.new(params[:credit_card])
      CreditCardPayment.for_card_and_customer(card, person.to_customer)
    else
      CashPayment.new(person.to_customer)
    end
  end

  def has_card_info?
    params[:credit_card].present? and params[:credit_card][:card_number].present?
  end

end