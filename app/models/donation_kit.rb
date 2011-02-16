class DonationKit < Kit
  acts_as_kit :with_approval => true do
    when_active do |organization|
      organization.can :receive, Donation
    end
  end
end