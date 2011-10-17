class Admin::SettlementsController < Admin::AdminController
  def index
    @start = params[:start].present? ? Time.zone.parse(params[:start]) : Time.now.beginning_of_month
    @stop  = params[:start].present? ? Time.zone.parse(params[:stop]).end_of_day : Time.now.end_of_day

    settlements_in_range = Settlement.in_range(@start, @stop)
    @settlements = settlements_in_range.sort{|a,b| b.created_at <=> a.created_at }.paginate(:page => params[:page], :per_page => 25)
  end

  def new
    @performance = Show.find(params[:show_id])
  end

  def create
    @performance = Show.find(params[:show_id])
    Settlement.submit(@performance.organization.id, @performance.settleables, @performance.organization.bank_account, @performance.id)
    redirect_to admin_settlements_path, :notice => "Submitted settlement request."
  end
end