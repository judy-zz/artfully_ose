class Store::CheckoutsController < Store::StoreController
  layout "cart"

  def new
    redirect_to(store_order_url, :alert => "This order is empty!") if current_cart.empty?
    @payment = Payment.new
    @checkout = Checkout.new(current_cart, @payment)
  end

  def create
    unless current_cart.unfinished?
      redirect_to store_order_url(current_cart), :notice => "This order is already finished!" and return
    end
    
    puts "$$$"
    puts params[:payment]
    puts "$$$"

    @payment = Payment.new(params[:payment])
    #The user_agreement parameter doesn't get set automatically, not sure why
    @payment.user_agreement = params[:payment][:user_agreement]
    @checkout = Checkout.for(current_cart, @payment)

    unless @checkout.valid?
      flash[:error] = @checkout.error || "An error occured while trying to validate your payment. Please review your information."
      #redirect_to store_order_url and return
      render :new and return
    end

    with_confirmation do
      if @checkout.finish
        redirect_to store_order_url(current_cart), :notice => 'Thank you for your order!'
      else
        flash[:error] = "An error occured while trying to validate your payment. Please review your information."
        render :new
      end
    end
  end

  def storefront_create
    unless current_cart.unfinished?
      render :json => "This order is already finished!", :status => :unprocessable_entity and return
    end

    @payment = Payment.new(params[:payment])
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

  private
    def with_confirmation
      if params[:confirmation].blank?
        @needs_confirmation = true
        flash[:notice] = 'Please confirm your payment details'
        render :new
      else
        yield
      end
    end
end