class Admin::UsersController < ApplicationController
  def index
    unless params[:email].blank?
      @user = User.find_by_email(params[:email])
      redirect_to edit_admin_user_path(@user) unless @user.nil?
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.suspend! params[:user][:suspension_reason] if params[:user][:suspend]
    if @user.suspended?
      redirect_to admin_user_path(@user), :notice => "Suspended #{@user.email}. Reason: #{@user.suspension_reason}" and return
    else
      render :edit and return
    end
  end
end
