class CreditCardsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @credit_cards = current_user.credit_cards
  end

  def new
    @credit_card = AthenaCreditCard.new
    @customer = AthenaCustomer.new if current_user.customer.nil?
  end

  def create
    @customer = build_customer

    @credit_card = AthenaCreditCard.new(params[:athena_credit_card][:athena_credit_card])
    @credit_card.customer = @customer

    if @credit_card.save
      redirect_to credit_cards_url, :notice => "Your card was saved."
    else
      render :new and return
    end

  end

  def edit
    @credit_card = AthenaCreditCard.find(params[:id])
  end

  def update
    @credit_card = AthenaCreditCard.find(params[:id])
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
    @credit_card.destroy
    redirect_to credit_cards_url
  end

  private
    def build_customer
      if current_user.customer.nil?
        current_user.customer = AthenaCustomer.create(params[:athena_credit_card][:athena_customer])
      end

      current_user.customer
    end
    
end
