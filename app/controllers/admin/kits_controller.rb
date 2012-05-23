class Admin::KitsController < Admin::AdminController
  def activate
    @kit = Kit.find(params[:id])
    @kit.approve!
    check_activation
    redirect_to :back
  end
  
  def cancel
    @kit = Kit.find(params[:id])
    @kit.cancel!
    redirect_to :back
  end

  def index
    @pending_kits = Kit.where(:state => "pending")
  end

  private
    def check_activation
      if @kit.activated?
        flash[:notice] = "This kit has been activated"
      else
        flash[:error] = @kit.errors[:requirements].join(", ")
      end
    end
end