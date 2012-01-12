class Admin::FinancesController < Admin::AdminController
  def index
    @start = params[:start].present? ? DateTime.parse(params[:start]) : Time.now.beginning_of_month
    @stop  = params[:start].present? ? DateTime.parse(params[:stop]).end_of_day : Time.now.end_of_day
    @orders = OrderView.artfully.paginate(:page => params[:page], :per_page => 50)
    settlements_in_range = Settlement.in_range(@start, @stop)
    @settlements = settlements_in_range.sort{|a,b| b.created_at <=> a.created_at }.paginate(:page => params[:page], :per_page => 25)
  end
end