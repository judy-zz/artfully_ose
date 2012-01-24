class Admin::FinancesController < Admin::AdminController
  def index
    @start = params[:start].present? ? DateTime.parse(params[:start]) : Time.now.beginning_of_week
    @stop  = params[:start].present? ? DateTime.parse(params[:stop]).end_of_day : Time.now.end_of_week
    @orders = OrderView.after(@start).before(@stop)
    @artfully_orders = OrderView.artfully.after(@start).before(@stop)
    settlements_in_range = Settlement.in_range(@start, @stop)
    @settlements = settlements_in_range.sort{|a,b| b.created_at <=> a.created_at }
    @summary = FinanceSummary.new(@orders, @settlements)
  end
end