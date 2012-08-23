class Admin::FinancesController < Admin::AdminController
  include AdminTimeZone
  
  def index    
    @orders = OrderView.includes(:items).after(start).before(stop)
    @artfully_orders = OrderView.artfully.includes(:items).after(start).before(stop)
    settlements_in_range = Settlement.in_range(start, stop)
    @settlements = settlements_in_range.sort{|a,b| b.created_at <=> a.created_at }
    @summary = FinanceSummary.new(@orders, @settlements)
  end
  
  def start
    @start ||= params[:start].present? ?
               ActiveSupport::TimeZone.create(time_zone).parse(params[:start]) :
               Time.now.beginning_of_week
  end
  
  def stop    
    @stop  ||= params[:stop].present? ? 
               ActiveSupport::TimeZone.create(time_zone).parse(params[:stop]).end_of_day : 
               Time.now.end_of_week
  end
end