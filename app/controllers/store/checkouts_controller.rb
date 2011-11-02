class Store::CheckoutsController < Store::StoreController
  layout "cart"

  def new
    redirect_to(store_order_url, :alert => "This order is empty!") if current_cart.empty?
    @payment = AthenaPayment.new
    @checkout = Checkout.new(current_cart, @payment)
  end

  def create
    unless current_cart.unfinished?
      redirect_to store_order_url(current_cart), :notice => "This order is already finished!" and return
    end

    @payment = AthenaPayment.new(params[:athena_payment])
    #The user_agreement parameter doesn't get set automatically, not sure why
    @payment.user_agreement = params[:athena_payment][:user_agreement]
    @checkout = Checkout.new(current_cart, @payment)

    unless @checkout.valid?
      flash[:error] = "An error occured while trying to validate your payment. Please review your information."
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