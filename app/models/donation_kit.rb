class DonationKit < Kit
  acts_as_kit :with_approval => true do

    grant_abilities do |organization|
      organization.can :receive, Donation
    end

  end
end