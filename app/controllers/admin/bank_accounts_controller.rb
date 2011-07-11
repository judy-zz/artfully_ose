class Admin::BankAccountsController < Admin::AdminController
  before_filter :find_organization

  def new
    @bank_account = BankAccount.new
  end

  def create
    @bank_account = @organization.build_bank_account(params[:bank_account])
    if @bank_account.save
      flash[:notice] = "Added a bank account to #{@organization.name}"
      redirect_to admin_organization_path(@organization)
    else
      render :new
    end
  end

  def edit
    @bank_account = @organization.bank_account
  end

  def update
    @bank_account = @organization.bank_account
    if @bank_account.update_attributes(params[:bank_account])
      flash[:notice] = "Updated bank account for #{@organization.name}"
      redirect_to admin_organization_path(@organization)
    else
      flash[:error] = "Unable to update bank account for #{@organization.name}"
      render :edit
    end
  end

  private

  def find_organization
    @organization = Organization.find(params[:organization_id])
  end

end
