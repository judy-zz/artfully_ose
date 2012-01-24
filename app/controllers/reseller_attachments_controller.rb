class ResellerAttachmentsController < ApplicationController

  before_filter :find_reseller_profile
  before_filter :find_parent
  before_filter :build_new_reseller_attachment
  before_filter :find_reseller_attachment, :except => [:new, :create]

  def new
  end

  def create
    if @reseller_attachment.save
      flash[:notice] = "You attachment has been added to the event."
      redirect_to organization_reseller_events_path(@organization)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @reseller_attachment.update_attributes(params[:reseller_attachment])
      flash[:notice] = "Your attachment has been updated."
      redirect_to organization_reseller_events_path(@organization)
    else
      render :edit
    end
  end

  protected

  def find_reseller_profile
    @organization = Organization.find(params[:organization_id])
    @reseller_profile = @organization.reseller_profile

    if !@reseller_profile
      flash[:error] = "Please create a reseller profile."
      redirect_to root_path
    end
  end

  def find_parent
    @parent = Event.find(params[:event_id]) if params[:event_id]
    @parent = Show.find(params[:show_id]) if params[:show_id]
    @parent = ResellerEvent.find(params[:reseller_event_id]) if params[:reseller_event_id]
  end

  def build_new_reseller_attachment
    @reseller_attachment = ResellerAttachment.new(params[:reseller_attachment])
    @reseller_attachment.reseller_profile = @reseller_profile
    @reseller_attachment.attachable = @parent if @parent
  end

  def find_reseller_attachment
    @reseller_attachment = @reseller_profile.reseller_attachments.find(params[:id])
  end

end
