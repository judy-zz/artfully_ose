class TransactionsController < ApplicationController
  def create
    @transaction = Transaction.new
    params[:tickets].each do |id|
      @transaction.tickets << Ticket.find(id)
    end

    @transaction.save
    redirect_to @transaction
  end

  def edit
  end

  def update
  end

  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy
  end

  def show
    @transaction = Transaction.find(params[:id])
  end
end
