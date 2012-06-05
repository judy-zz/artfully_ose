class Admin::IndexController < Admin::AdminController
  def index
    @top_organizations = Organization.order('lifetime_value desc').limit(3)
  end
end
