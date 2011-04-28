class AdminMailer < ActionMailer::Base
  default :from => "noreply@artful.ly"
  layout "mail"

  def donation_kit_notification(kit)
    @kit = kit
    @organization = kit.organization
    
    mail :to => "support@fracturedatlas.org", :subject => "Artful.ly: Pending Donation Kit for #{@organization.name}"
  end
end
