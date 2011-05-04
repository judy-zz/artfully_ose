class SponsoredDonationKit < Kit
  acts_as_kit :with_approval => true do
    activate_kit :if => :connected?

    when_active do |organization|
      organization.can :receive, Donation
    end
  end

  def connected?
    errors.add(:requirements, "You need to connect to your Fractured Atlas Membership to active this kit") unless organization.connected?
    organization.connected?
  end

  def alternatives
    @alternatives = [ RegularDonationKit ]
  end
end