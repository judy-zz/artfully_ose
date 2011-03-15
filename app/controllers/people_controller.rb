class PeopleController < ApplicationController

  def index
    if params[:email]
      begin
        @person = AthenaPerson.find_by_email_and_organization(params[:email], current_user.current_organization)
        redirect_to person_url(@person) if @person
      rescue
        flash[:error] = "No people records for this email address."
      end
    end
  end

  def show
    @person = AthenaPerson.find(params[:id])
  end

  def edit
  end

  def update
  end

end