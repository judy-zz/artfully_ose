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

          if current_order.user = create_user
            update_people_record(current_order.user)
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
      flash[:notice] = 'Thank you for your order!'
      redirect_to store_order_url(current_order)
    end

    def request_confirmation
      @needs_confirmation = true
      flash[:notice] = 'Please confirm your payment details'
      render :new
    end

    def create_user
      password = params[:options].delete(:password)
      password_confirmation = params[:options].delete(:password_confirmation)

      password = password_confirmation = User.generate_password if password.blank?

      User.find_by_email(@payment.customer.email) || User.create(:email => @payment.customer.email, :password => password, :password_confirmation => password_confirmation)
    end

    def update_people_record(user)
      logger.info user.errors
      user.person.update_attributes(:first_name => @payment.customer.first_name,
                                      :last_name  => @payment.customer.last_name)
    end

    def save_customer
      @payment.customer.credit_card = @payment.credit_card
      if @payment.customer.save
        flash[:notice] = "Successfully saved your information."
      else
        flash[:error] = "Unable to save your information."
      end
    end

    def should_save_customer?
      params[:options][:save] == 1
    end
end