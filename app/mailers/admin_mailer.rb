class AdminMailer < ActionMailer::Base
  default :from => "support@artful.ly"
  layout "mail"
  add_template_helper(ApplicationHelper)

  def settlement_summary(shows, settlements = [])
    @shows = shows
    @settlements = settlements
    mail :to => "gary.moore@fracturedatlas.org", :subject => "Artful.ly: Settlement report for #{DateTime.now.strftime("%m/%d/%y")}"
  end

  def reseller_settlement_summary(settlements = [])
    @settlements = settlements
    mail :to => "gary.moore@fracturedatlas.org", :subject => "Artful.ly: Settlement report for #{DateTime.now.strftime("%m/%d/%y")}"
  end

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

  def reseller_kit_notification(kit)
    @kit = kit
    @organization = kit.organization

    mail :to => "support@artful.ly", :subject => "Artful.ly: Pending Reseller Kit for #{@organization.name}"
  end
end
