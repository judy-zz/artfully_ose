class PeopleController < ApplicationController

  def index
    @people = []
    if params[:email]
      begin
        person = AthenaPerson.find_by_email_and_organization(params[:email], current_user.current_organization)
      rescue
        flash[:error] = "No results found."
      end
    end
    @people << person unless person.nil?
  end

  def show
    @person = AthenaPerson.find(params[:id])
  end

  def edit
  end

  def update
  end

end