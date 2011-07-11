class Admin::SettlementsController < Admin::AdminController
  def index
    @settlements = Settlement.find(:all, :params =>{ :createdAt => "lt#{DateTime.now.xmlschema}"}).paginate(:page => params[:page], :per_page => 25)
  end

  def new
    @performance = AthenaPerformance.find(params[:performance_id])
  end

  def create
    @performance = AthenaPerformance.find(params[:performance_id])
    Settlement.submit(@performance.organization.id, @performance.settleables, @performance.organization.bank_account)
    redirect_to admin_settlements_path, :notice => "Submitted settlement request."
  end
end