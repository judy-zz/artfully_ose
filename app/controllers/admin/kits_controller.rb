class Admin::KitsController < Admin::AdminController
  def activate
    @kit = Kit.find(params[:id])
    @kit.activate!
    check_activation
    redirect_to kits_url
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