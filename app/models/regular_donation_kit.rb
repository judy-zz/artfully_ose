class RegularDonationKit < Kit
  acts_as_kit :with_approval => true do
    activate_kit :if => :has_tax_info?
    activate_kit :if => :exclusive?

    when_active do |organization|
      organization.can :receive, Donation
    end
  end

  def has_tax_info?
    errors.add(:requirements, "You need to enter your tax information to active this kit.") unless organization.has_tax_info?
    organization.has_tax_info?
  end

  def exclusive?
    exclusive = !organization.kits.where(:type => alternatives.collect(&:to_s)).any?
    errors.add(:requirements, "You have already activated a mutually exclusive kit.") unless exclusive
    exclusive
  end

  def alternatives
    @alternatives ||= [ SponsoredDonationKit ]
  end

  def on_pending
    AdminMailer.donation_kit_notification(self).deliver
    ProducerMailer.donation_kit_notification(self, organization.owner).deliver
  end
end