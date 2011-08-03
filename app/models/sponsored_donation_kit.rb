class SponsoredDonationKit < Kit
  acts_as_kit :with_approval => true do
    activate :if => :connected?
    activate :if => :exclusive?
    activate :if => :has_website?

    when_active do |organization|
      organization.can :receive, Donation
    end
  end

  def connected?
    errors.add(:requirements, "You need to connect to your Fractured Atlas Membership to active this kit") unless organization.connected?
    organization.connected?
  end

  def exclusive?
    exclusive = !organization.kits.where(:type => alternatives.collect(&:to_s)).any?
    errors.add(:requirements, "You have already activated a mutually exclusive kit.") unless exclusive
    exclusive
  end

  # def alternatives
  #   @alternatives ||= [ RegularDonationKit ]
  # end

  def has_website?
    errors.add(:requirements, "You need to specify a website for your organization.") unless !organization.website.blank?
    !organization.website.blank?
  end

  def on_pending
    AdminMailer.donation_kit_notification(self).deliver
    ProducerMailer.donation_kit_notification(self, self.organization.owner).deliver
  end
end