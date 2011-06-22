class Admin::SettlementsController < Admin::AdminController
  def index
    @settlements = Settlement.find(:all, :params =>{ :createdAt => "lt#{DateTime.now.xmlschema}"}).paginate(:page => params[:page], :per_page => 25)
  end
end