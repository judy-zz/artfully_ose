class StatementsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @events = AthenaEvent.find(:all, :params => { :organizationId => "eq#{current_user.current_organization.id}" })
  end

  def show
  end
end