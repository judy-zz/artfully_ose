class OrdersController < ApplicationController
  def create
    @order = Order.new
    @order.tickets = params[:tickets]
    if @order.save
      redirect_to edit_order_url(@order)
    else
      flash[:error] = @order.errors
      redirect_to :back
    end
  end

  def edit
    @order = Order.find(params[:id])
    @payment = Athena::Payment.new
  end

  def update
    @order = Order.find(params[:id])

    if @order.unfinished?
      @payment = Athena::Payment.new(params[:athena_payment])
      @payment.amount = @order.total

      if @payment.valid?
        if payment_confirmed?
          if create_user
            @order.user = @user
            @order.save
          else
            request_confirmation and return
          end

          save_customer if should_save_customer?
          submit_payment and return
        else
          request_confirmation and return
        end
      else
        render :edit and return
      end
    else
      redirect_to @order, :notice => "This order is already finished!"
    end
  end

  def destroy
    Order.find(params[:id]).destroy
    redirect_to root_url
  end

  def show
    @order = Order.find(params[:id])
  end

  private
    def payment_confirmed?
      not params[:confirmation].blank?
    end

    def submit_payment
      @order.pay_with(@payment)
      @order.save
      flash[:notice] << 'Thank you for your order!'
      redirect_to @order
    end

    def request_confirmation
      @needs_confirmation = true
      flash[:notice] = 'Please confirm your payment details'
      render :edit
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
