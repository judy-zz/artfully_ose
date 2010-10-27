class PaymentsController < ApplicationController
  def create
    @transaction = Transaction.find(params[:transaction])
    @payment = Payment.new(params[:payment])
    @payment.amount = 10
    if @payment.valid?
      if @payment.confirmed?
        #save
      else
        render 'payments/show'
      end
    else
      render 'transactions/show'
    end

  end

  def edit
  end

  def update
  end
end
