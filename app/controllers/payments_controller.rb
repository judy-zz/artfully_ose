class PaymentsController < ApplicationController
  def create
    @payment = Payment.new(params[:payment])
    if @payment.valid?
#     @payment.save
#     redirect_to @payment
    else
      render :action => "new"
    end

  end

  def edit
  end

  def update
  end
end
