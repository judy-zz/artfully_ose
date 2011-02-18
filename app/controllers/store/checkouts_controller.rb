class Store::CheckoutsController < Store::StoreController
  layout "widget"

  def new
    redirect_to(store_order_url, :alert => "This order is empty!") if current_order.empty?
    @payment = AthenaPayment.new
  end

  def create
    if current_order.unfinished?
      @payment = AthenaPayment.new(params[:athena_payment])
      @payment.amount = current_order.total

      if @payment.valid?
        if payment_confirmed?
          if create_user
            current_order.user = @user
            current_order.save
          else
            request_confirmation and return
          end

          save_customer if should_save_customer?
          submit_payment and return
        else
          request_confirmation and return
        end
      else
        render :new and return
      end
    else
      redirect_to store_order_url(current_order), :notice => "This order is already finished!"
    end
  end

  private
    def payment_confirmed?
      not params[:confirmation].blank?
    end

    def submit_payment
      current_order.pay_with(@payment)
      current_order.save
      flash[:notice] << 'Thank you for your order!'
      redirect_to store_order_url(current_order)
    end

    def request_confirmation
      @needs_confirmation = true
      flash[:notice] = 'Please confirm your payment details'
      render :new
    end

    def create_user
      @user = User.new(:email => @payment.customer.email,
                       :password => params[:options][:password],
                       :passoword_confirmation => params[:options][:password_confirmation])
      @user.save
    end

    def save_customer
      @payment.customer.credit_card = @payment.credit_card
      if @payment.customer.save
        flash[:notice] = ["Successfully saved your information."]
      else
        flash[:error] = ["Unable to save your information."]
      end
    end

    def should_save_customer?
      params[:options][:save]
    end
end