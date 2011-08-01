class Admin::SettlementsController < Admin::AdminController
  def index
    begin
      Time.zone = current_user.current_organization.time_zone
      unless params[:commit].blank?
        @start = Time.zone.parse(Date.strptime(params[:start], "%m/%d/%Y").to_s)
        @stop  = Time.zone.parse(Date.strptime(params[:stop] , "%m/%d/%Y").to_s).end_of_day
      else
        @start = DateTime.now.in_time_zone(Time.zone).beginning_of_month
        @stop  = DateTime.now.in_time_zone(Time.zone).end_of_day
      end
      settlements_range = Settlement.in_range(@start, @stop, current_user.current_organization.id)
      @settlements_range = settlements_range.sort{|a,b| b.timestamp <=> a.timestamp }.paginate(:page => params[:page], :per_page => 25)
    rescue ArgumentError
      flash[:alert] = "One or both of the dates entered are invalid."
      redirect_to :back
    end
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