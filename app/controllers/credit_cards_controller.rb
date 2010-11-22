class CreditCardsController < ApplicationController
  def index
    @credit_cards = current_user.credit_cards
    render :template => 'athena_credit_cards/index'
  end

  def show
    render :template => 'athena_credit_cards/show'
  end

  def destroy
    @credit_card = AthenaCreditCard.find(params[:id])
    @credit_card.destroy
    redirect_to user_credit_cards_url(current_user)
  end
end
