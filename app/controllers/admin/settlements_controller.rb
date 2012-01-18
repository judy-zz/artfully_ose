class Admin::SettlementsController < Admin::AdminController
  def index
    @start = params[:start].present? ? DateTime.parse(params[:start]) : Time.now.beginning_of_month
    @stop  = params[:start].present? ? DateTime.parse(params[:stop]).end_of_day : Time.now.end_of_day

    settlements_in_range = Settlement.in_range(@start, @stop)
    @settlements = settlements_in_range.sort{|a,b| b.created_at <=> a.created_at }
  end

  def new
    @show = Show.find(params[:show_id])
  end

  def create
    @show = Show.find(params[:show_id])
    Settlement.submit(@show.organization.id, @show.settleables, @show.organization.bank_account, @show.id)
    redirect_to admin_settlements_path, :notice => "Submitted settlement request."
  end
end