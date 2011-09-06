class ContributionsController < ApplicationController
  def index
    authorize! :manage, AthenaOrder
    Time.zone = current_user.current_organization.time_zone

    @search = DonationSearch.new(params[:start], params[:stop], current_user.current_organization) do |results|
      results.paginate(:page => params[:page], :per_page => 10)
    end
  end

  def new
    @contribution = create_contribution
    if @contribution.has_contributor?
      render :new
    else
      @contributors = contributors
      render :find_person
    end
  end

  def create
    @contribution = create_contribution
    @contribution.save
    redirect_to contributions_path
  end

  private

  def contributors
    if params[:terms].present?
      people = AthenaPerson.search_index(params[:terms].dup, current_user.current_organization)
      flash[:error] = "No people matched your search terms." if people.empty?
    end
    people || []
  end

  def create_contribution
    params[:contribution] ||= {}
    Contribution.new(params[:contribution].merge(:organization_id => current_user.current_organization.id))
  end
end