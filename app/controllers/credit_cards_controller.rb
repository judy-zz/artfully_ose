class CreditCardsController < ApplicationController
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to dashboard_path
  end

  def index
    @credit_cards = current_user.credit_cards
  end

  def new
    @credit_card = AthenaCreditCard.new
    @customer = AthenaCustomer.new if current_user.customer.nil?
  end

  def create
    @customer = current_user.customer || AthenaCustomer.new(params[:athena_credit_card][:athena_customer])
    @credit_card = AthenaCreditCard.new(params[:athena_credit_card][:athena_credit_card])

    if @customer.valid? and @credit_card.valid?
      if @customer.new_record?
        @customer.save
        current_user.customer = @customer
      end
      @credit_card.customer = @customer
      @credit_card.save
      redirect_to credit_cards_url, :notice => "Your card was saved."
    else
      render :new and return
    end
  end

  def edit
    @credit_card = AthenaCreditCard.find(params[:id])
    authorize! :edit, @credit_card
  end

  def update
    @credit_card = AthenaCreditCard.find(params[:id])
    authorize! :edit, @credit_card
    # TODO: Fix form_for nested fields issue.
    @credit_card.update_attributes(params[:athena_credit_card][:athena_credit_card])
    if @credit_card.save
      redirect_to credit_cards_url
    else
      render :edit and return
    end
  end

  def destroy
    @credit_card = AthenaCreditCard.find(params[:id])
    authorize! :destroy, @credit_card
    @credit_card.destroy
    redirect_to credit_cards_url
  end
end
