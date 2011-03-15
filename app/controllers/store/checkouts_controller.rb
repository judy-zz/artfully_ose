class Store::CheckoutsController < Store::StoreController
  layout "widget"

  def new
    redirect_to(store_order_url, :alert => "This order is empty!") if current_order.empty?
    @payment = AthenaPayment.new
    @checkout = Checkout.new(current_order, @payment)
  end

  def create
    unless current_order.unfinished?
      redirect_to store_order_url(current_order), :notice => "This order is already finished!" and return
    end

    @payment = AthenaPayment.new(params[:athena_payment])
    @checkout = Checkout.new(current_order, @payment)

    unless @checkout.valid?
      render :new and return
    end

    with_confirmation do
      @checkout.finish
      redirect_to store_order_url(current_order), :notice => 'Thank you for your order!'
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