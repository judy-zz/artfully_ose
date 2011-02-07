class CreditCardsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @credit_cards = current_user.credit_cards
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
end
