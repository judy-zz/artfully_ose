class UserRolesController < ApplicationController
  before_filter :authenticate_user!

  def new
    @credit_card = AthenaCreditCard.new
    @customer = AthenaCustomer.new
    @user_role = UserRole.new
    @organization = Organization.new
  end

  def create
    @user_role = UserRole.new
    @customer = AthenaCustomer.new(params[:user_role][:athena_customer])
    @credit_card = AthenaCreditCard.new(params[:user_role][:athena_credit_card])
    @organization = Organization.new(params[:user_role][:organization])
    @credit_card.valid?
    @customer.valid?
    @organization.valid?

    if @credit_card.valid? and @customer.valid? and @organization.valid?
      @customer.save
      @credit_card.customer = @customer
      @credit_card.save
      current_user.customer = @customer
      current_user.organization = @organization
      current_user.to_producer and current_user.save!
      redirect_to root_url, :notice => "Congratulations! You now have access to producer features"
    else
      render :new
    end
  end
end
