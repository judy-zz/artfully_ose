class ResellerAttachmentsController < ApplicationController

  before_filter :find_reseller_profile
  before_filter :find_parent
  before_filter :rewrite_s3_response, :only => [:create]

  def new
    @reseller_attachment = @reseller_profile.reseller_attachments.build
    @reseller_attachment.event = @parent
  end

  def create
    @reseller_attachment = ResellerAttachment.new(params[:reseller_attachment])
    @reseller_attachment.reseller_profile = @reseller_profile
    @reseller_attachment.event = @parent if @parent

    if @reseller_attachment.save
      flash[:notice] = "Your picture has been attached to the event."
      redirect_to organization_reseller_events_path(@organization)
    else
      render :new
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

end
