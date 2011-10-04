class AdminMailer < ActionMailer::Base
  default :from => "support@artful.ly"
  layout "mail"

  def ticketing_kit_notification(kit)
    @kit = kit
    @organization = kit.organization

    mail :to => "support@artful.ly", :subject => "Artful.ly: Pending Ticketing Kit for #{@organization.name}"
  end

  def donation_kit_notification(kit)
    @kit = kit
    @organization = kit.organization

    mail :to => "support@artful.ly", :subject => "Artful.ly: Pending Donation Kit for #{@organization.name}"
  end

  def sponsored_donation_kit_notification(kit)
    @kit = kit
    @organization = kit.organization

    mail :to => "support@artful.ly", :subject => "Artful.ly: Pending Sponsored Donation Kit for #{@organization.name}"
  end
end
