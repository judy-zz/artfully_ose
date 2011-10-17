class ProducerMailer < ActionMailer::Base
  default :from => "support@artful.ly"
  layout "mail"

  def donation_kit_notification(kit, producer)
    @kit = kit
    @organization = kit.organization
    @producer = producer

    mail :to => producer.email, :subject => "Artful.ly: Complete Donation Kit Activation for #{@organization.name}"
  end
end
