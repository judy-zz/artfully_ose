class UserRolesController < ApplicationController
  def new
    @credit_card = Athena::CreditCard.new
    @user_role = UserRole.new
  end

  def create
    @user_role = UserRole.new
    @credit_card = Athena::CreditCard.new(params[:user_role][:athena_credit_card])
    if @credit_card.valid?
      current_user.to_producer!
      redirect_to current_user, :notice => "Congratulations! You now have access to producer features"
    else
      render :new
    end
  end
end
