class RegularDonationKit < Kit
  acts_as_kit :with_approval => true do
    activate_kit :unless => :tax_info?

    when_active do |organization|
      organization.can :receive, Donation
    end
  end

  def tax_info?
    errors.add(:requirements, "You need to enter your tax information to active this kit") unless organization.has_tax_info?
    !organization.has_tax_info?
  end

  def alternatives
    @alternatives = [ SponsoredDonationKit ]
  end
end