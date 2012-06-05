class Admin::IndexController < Admin::AdminController
  def index
    @top_organizations = Organization.order('lifetime_value desc').limit(10)
  end
end
