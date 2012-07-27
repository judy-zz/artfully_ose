class Store::CheckoutsController < Store::StoreController
  layout "cart"

  def create
    unless current_cart.unfinished?
      render :json => "This order is already finished!", :status => :unprocessable_entity and return
    end

    @payment = CreditCardPayment.new(params[:payment])
    #The user_agreement parameter doesn't get set automatically, not sure why
    @payment.user_agreement = params[:payment][:user_agreement]
    current_cart.special_instructions = params[:special_instructions]
    @checkout = Checkout.new(current_cart, @payment)

    if @checkout.valid? && @checkout.finish
      render :json => @checkout.to_json
    else
      message = @payment.errors.full_messages.to_sentence.downcase
      message = message.gsub('customer', 'contact info')
      message = message.gsub('credit card is', 'payment details are')
      message = message[0].upcase + message[1..message.length] unless message.blank? #capitalize first word
      render :json => message, :status => :unprocessable_entity
    end
  end
end