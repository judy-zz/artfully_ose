class IndexController < ArtfullyOseController

  skip_before_filter :authenticate_user!, :only => [:index]

  def index
    redirect_to admin_root_path if admin_signed_in?
  end

  def login_success
    redirect_to root_path
  end

  def dashboard
    if current_user.is_in_organization?
      @events = current_user.current_organization.events.includes(:shows, :venue).order('updated_at DESC').limit(4)
      @recent_actions = Action.recent(current_user.current_organization, 10).where('import_id is null')
    end
  end

end
