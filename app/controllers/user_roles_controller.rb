class UserRolesController < ApplicationController
  def new
    @credit_card = Athena::CreditCard.new
    @customer = Athena::Customer.new
    @user_role = UserRole.new
  end

  def create
    @user_role = UserRole.new
    @customer = Athena::Customer.new(params[:user_role][:athena_customer])
    @credit_card = Athena::CreditCard.new(params[:user_role][:athena_credit_card])
    @credit_card.valid?
    @customer.valid?

    if @credit_card.valid? and @customer.valid?
      @customer.save
      @credit_card.customer = @customer
      @credit_card.save
      current_user.customer = @customer
      current_user.to_producer!
      redirect_to current_user, :notice => "Congratulations! You now have access to producer features"
    else
      render :new
    end
  end
end
